"""Run focused CPU-level checks on built ROMs, using isolated in-memory saves.

Graphics, audio and text entry points may be stubbed with RET; gameplay code,
ROM data, banking and RAM writes execute in PyBoy's Game Boy CPU emulator.
"""

import io
from fractions import Fraction
from itertools import product
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from pyboy import PyBoy

from dialogue_width import dialogue_issues, line_width


ROOT = Path(__file__).resolve().parents[1]


def read_symbols(path):
    symbols = {}
    for line in path.read_text().splitlines():
        fields = line.split()
        if len(fields) == 2 and ":" in fields[0] and not line.startswith(";"):
            bank, address = fields[0].split(":")
            symbols[fields[1]] = (int(bank, 16), int(address, 16))
    return symbols


def read_constants():
    with tempfile.TemporaryDirectory(prefix="pokered-test-constants-") as tmp:
        obj = Path(tmp) / "constants.o"
        result = subprocess.run([os.environ.get("RGBASM", "rgbasm"), "-o", str(obj),
                                 "tests/constants.asm"], cwd=ROOT, check=True,
                                capture_output=True, text=True)
        return {name: int(value) for name, value in
                (line.split("=") for line in result.stdout.splitlines())}


class GameplayTests(unittest.TestCase):
    rom = ROOT / "pokered.gbc"
    constants = {}

    def setUp(self):
        self.symbols = read_symbols(self.rom.with_suffix(".sym"))
        self.gb = PyBoy(io.BytesIO(self.rom.read_bytes()), ram_file=io.BytesIO(bytes(0x8000)),
                        window="null", sound_emulated=False, log_level="ERROR")
        self.gb.set_emulation_speed(0)
        self.gb.memory[0xFF50] = 1  # Bypass the boot ROM; run only the named routine.
        self.gb.memory[0xFFFF] = 0  # Disable hardware interrupts for isolated calls.
        self.gb.memory[0xC000:0xE000] = [0] * 0x2000
        self.addCleanup(self.gb.stop, save=False)

    def address(self, name):
        return self.symbols[name][1]

    def const(self, name):
        return self.constants[name]

    def rom_bytes(self, name, count, offset=0):
        bank, address = self.symbols[name]
        return [self.gb.memory[bank, address + offset + i] for i in range(count)]

    def overworld_walkable(self, name, avoid_grass=False):
        tileset, height, width = self.rom_bytes(name + "_h", 3)
        self.assertEqual(tileset, self.const("OVERWORLD"))
        layout = self.rom_bytes(name + "_Blocks", width * height)
        collision = self.rom_bytes("Overworld_Coll", 64)
        collision = set(collision[:collision.index(255)])
        if avoid_grass:
            collision.discard(0x52)  # OVERWORLD's tall-grass collision tile.
        walkable = set()
        for y in range(height * 2):
            for x in range(width * 2):
                block = layout[y // 2 * width + x // 2]
                tile_offset = block * 16 + (y % 2 * 2 + 1) * 4 + x % 2 * 2
                if self.rom_bytes("Overworld_Block", 1, tile_offset)[0] in collision:
                    walkable.add((x, y))
        return walkable

    def put(self, name, values):
        if isinstance(values, int):
            values = [values]
        address = self.address(name)
        self.gb.memory[address:address + len(values)] = values

    def get(self, name, length=1):
        address = self.address(name)
        values = self.gb.memory[address:address + length]
        return values[0] if length == 1 else values

    def set_event(self, name, enabled=True):
        event = self.const(name)
        address = self.address("wEventFlags") + event // 8
        mask = 1 << (event % 8)
        value = self.gb.memory[address]
        self.gb.memory[address] = value | mask if enabled else value & ~mask

    def reminder_moves(self):
        start = self.address("wItemList") + 1
        return [self.gb.memory[start + i] for i in range(self.get("wItemList"))]

    def event_set(self, name):
        event = self.const(name)
        return bool(self.gb.memory[self.address("wEventFlags") + event // 8] & (1 << (event % 8)))

    def object_hidden(self, name):
        index = self.const(name)
        return bool(self.gb.memory[self.address("wToggleableObjectFlags") + index // 8] & (1 << (index % 8)))

    def put_hp(self, name, value):
        self.put(name, list(value.to_bytes(2, "big")))

    def hp(self, name):
        return int.from_bytes(self.get(name, 2), "big")

    def stub(self, *names):
        for name in names:
            bank, address = self.symbols[name]
            self.gb.memory[bank, address] = 0xC9  # RET

    def record_dialogue(self):
        self.stub("PrintText", "TextScriptEnd")
        printed = []
        self.gb.hook_register(*self.symbols["PrintText"],
                              lambda _: printed.append(self.gb.register_file.HL), None)
        return printed

    def call(self, name, offset=0, **registers):
        bank, address = self.symbols[name]
        if offset == 1:
            self.assertEqual(self.gb.memory[bank, address], 0x08, "Expected a text_asm entry point")
        address += offset
        self.gb.memory[0x2000] = bank or 1
        self.put("hLoadedROMBank", bank or 1)
        # DI; CALL routine; JP $FF84. The loop makes completion observable.
        self.gb.memory[0xFF80:0xFF87] = [0xF3, 0xCD, address & 255, address >> 8,
                                       0xC3, 0x84, 0xFF]
        cpu = self.gb.register_file
        cpu.SP = 0xDFF0
        for register, value in registers.items():
            setattr(cpu, register, value)
        cpu.PC = 0xFF80
        self.gb.tick(10, render=False, sound=False)
        self.assertEqual(cpu.PC, 0xFF84, f"{name} did not return")
        self.assertEqual(cpu.SP, 0xDFF0, f"{name} unbalanced the stack")

    def test_garden_entrance_and_visible_exit_match_compiled_collision(self):
        walkable = self.overworld_walkable("BillsSecretGarden")
        _, _, y, x = self.rom_bytes("BillsSecretGarden_Entrance", 4)
        self.assertIn((x, y), walkable, "Arrival must be on walkable ground")
        self.assertIn((x, y - 1), walkable, "Arrival must open into the garden")
        bottom = {position for position in walkable if position[1] == 17}
        self.assertEqual(bottom, {(14, 17), (15, 17)})
        warp_flags = ((1 << self.const("BIT_FORCE_DESTINATION_WARP_POSITION")) |
                      (1 << self.const("BIT_WARP_FROM_CUR_SCRIPT")))
        for x, y in walkable:
            self.put("wXCoord", x)
            self.put("wYCoord", y)
            self.put("wStatusFlags3", 0)
            self.put("hWarpDestinationMap", 255)
            self.call("BillsSecretGardenCheckExit")
            self.assertEqual(self.get("hWarpDestinationMap"),
                             self.const("ROUTE_25") if (x, y) in bottom else 255)
            self.assertEqual(self.get("wStatusFlags3"), warp_flags if (x, y) in bottom else 0)
            if (x, y) in bottom:
                self.assertEqual(self.get("wDestinationWarpID"), 1)
        _, _, y, x = self.rom_bytes("Route25_GardenReturn", 4)
        self.assertIn((x, y), self.overworld_walkable("Route25"))
        self.assertEqual((x, y), (51, 4))

    def test_garden_landmarks_have_an_encounter_free_approach(self):
        walkable = self.overworld_walkable("BillsSecretGarden", avoid_grass=True)
        walkable -= {(11, 3), (14, 6), (14, 7)}  # Pikachu, notebook, chair.
        _, _, y, x = self.rom_bytes("BillsSecretGarden_Entrance", 4)
        reachable = {(x, y)}
        pending = [(x, y)]
        while pending:
            x, y = pending.pop()
            for next_pos in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if next_pos in walkable and next_pos not in reachable:
                    reachable.add(next_pos)
                    pending.append(next_pos)
        for position in ((10, 3), (13, 6), (15, 6)):
            self.assertIn(position, reachable)

    def test_garden_route25_gate_preserves_unlock_and_arrival(self):
        self.stub("PrintText", "PlaySound", "TextScriptEnd")
        for unlocked in (False, True):
            self.set_event("EVENT_UNLOCKED_BILLS_SECRET_GARDEN", unlocked)
            self.put("hWarpDestinationMap", 255)
            self.put("wDestinationWarpID", 255)
            self.call("Route25SecretGardenGateText", offset=1)
            self.assertEqual(self.get("hWarpDestinationMap"),
                             self.const("BILLS_SECRET_GARDEN") if unlocked else 255)
            self.assertEqual(self.get("wDestinationWarpID"), 0 if unlocked else 255)

    def test_garden_pond_bank_keeps_all_reflection_spots_accessible(self):
        walkable = self.overworld_walkable("BillsSecretGarden", avoid_grass=True)
        # The three existing background-event positions remain dry, reachable banks.
        data = self.rom_bytes("BillsSecretGarden_Object", 12)
        self.assertEqual(data[1:3], [0, 3])  # No ordinary warps; three pond events.
        for i in range(3):
            y, x, _ = data[3 + i * 3:6 + i * 3]
            self.assertIn((x, y), walkable)
            self.assertIn((x, y + 1), walkable)

    def test_expanded_overworld_and_relocated_plateau_tileset_pointers(self):
        for name, tileset in (("Overworld", "OVERWORLD"), ("Plateau", "PLATEAU")):
            bank, block_lo, block_hi, gfx_lo, gfx_hi = self.rom_bytes(
                "Tilesets", 5, self.const(tileset) * 12)
            self.assertEqual((bank, block_lo | block_hi << 8), self.symbols[name + "_Block"])
            self.assertEqual((bank, gfx_lo | gfx_hi << 8), self.symbols[name + "_GFX"])

    def test_garden_gift_party_and_box(self):
        moves = [self.const(move) for move in
                 ("THUNDERBOLT", "SURF", "THUNDER_WAVE", "QUICK_ATTACK")]
        for party_count, in_party in ((1, True), (6, True), (6, False)):
            with self.subTest(party_count=party_count, in_party=in_party):
                self.put("wPartyCount", party_count)
                self.put("wAddedToParty", int(in_party))
                mon = f"wPartyMon{party_count}" if in_party else "wBoxMon1"
                size = self.const("PARTYMON_STRUCT_LENGTH" if in_party else "BOXMON_STRUCT_LENGTH")
                start = self.address(mon)
                self.gb.memory[start - 1:start + size + 1] = [0xA5] + [0] * size + [0xA5]
                self.gb.memory[start] = self.const("PIKACHU")
                self.call("BillsSecretGardenCustomizePikachu")
                self.assertEqual(self.get(mon + "Moves", 4), moves)
                self.assertEqual(self.get(mon + "PP", 4), [15, 15, 20, 30])
                self.assertEqual(self.get(mon + "DVs", 2), [0xEA, 0xAA])
                self.assertGreater(sum(self.get(mon + "HP", 2)), 0)
                if in_party:
                    self.assertEqual(self.get(mon + "HP", 2), self.get(mon + "MaxHP", 2))
                self.assertEqual(self.gb.memory[start - 1], 0xA5)
                self.assertEqual(self.gb.memory[start + size], 0xA5)

    def test_garden_butterfree_is_a_safe_post_gift_visitor(self):
        self.put("wCurMap", self.const("BILLS_SECRET_GARDEN"))
        self.call("MarkTownVisitedAndLoadToggleableObjects")
        original_toggles = self.get("wToggleableObjectList", 3)
        self.assertEqual([self.const("BILLSSECRETGARDEN_" + name) for name in
                          ("PIKACHU", "NOTEBOOK", "CHAIR", "BUTTERFREE")], [1, 2, 3, 4])
        data = self.rom_bytes("BillsSecretGarden_Object", 37)
        self.assertEqual(data[12], 4)
        self.assertEqual(data[31:37], [self.const("SPRITE_BIRD"), 13, 8,
                                      self.const("WALK"), self.const("ANY_DIR"),
                                      4])
        self.assertEqual(int.from_bytes(self.rom_bytes("BillsSecretGarden_TextPointers", 2, 6), "little"),
                         self.address("BillsSecretGardenButterfreeText"))
        self.assertIn((4, 9), self.overworld_walkable("BillsSecretGarden", avoid_grass=True))
        for received in (False, True):
            self.set_event("EVENT_GOT_BILLS_GARDEN_PIKACHU", received)
            for butterfly in ((4, 9), (5, 8)):
                self.put("wSprite04StateData2MapX", butterfly[0] + 4)
                self.put("wSprite04StateData2MapY", butterfly[1] + 4)
                for position in (butterfly, (15, 16), (4, 8)):
                    self.put("wXCoord", position[0])
                    self.put("wYCoord", position[1])
                    self.put("hCurrentSpriteOffset", self.const("BILLSSECRETGARDEN_BUTTERFREE") * 16)
                    self.call("IsObjectHidden")
                    self.assertEqual(bool(self.get("hIsToggleableObjectOff")),
                                     not received or position == butterfly)
        self.assertEqual(self.get("wToggleableObjectList", 3), original_toggles)
        printed = self.record_dialogue()
        self.stub("PlayCry", "WaitForSoundToFinish")
        cries = []
        self.gb.hook_register(*self.symbols["PlayCry"],
                              lambda _: cries.append(self.gb.register_file.A), None)
        self.call("BillsSecretGardenButterfreeText", offset=1)
        self.assertEqual(cries, [self.const("BUTTERFREE")])
        self.assertEqual(printed, [self.address("BillsSecretGardenButterfreeText.FlowersText")])
        self.assertEqual(self.get("wCurOpponent"), 0)
        self.assertEqual(self.get("wPartyCount"), 0)

    def test_garden_skim_waits_for_a_visible_idle_approach(self):
        self.stub("PlayCry", "UpdateSprites", "DelayFrame")
        started = []
        self.gb.hook_register(*self.symbols["MoveSprite"],
                              lambda _: started.append(True), None)
        guards = [("wWalkCounter", 1), ("wJoyIgnore", 255),
                  ("wWalkBikeSurfState", 2),
                  ("wFontLoaded", 1 << self.const("BIT_FONT_LOADED")),
                  ("wStatusFlags5", 1 << self.const("BIT_SCRIPTED_NPC_MOVEMENT")),
                  ("wStatusFlags5", 1 << self.const("BIT_SCRIPTED_MOVEMENT_STATE")),
                  ("wUpdateSpritesEnabled", 0)]
        for field, value in guards:
            with self.subTest(field=field, value=value):
                self.put("wXCoord", 12)
                self.put("wYCoord", 6)
                self.put("wUpdateSpritesEnabled", 1)
                self.put(field, value)
                self.call("BillsSecretGardenTryPikachuSkim")
                self.put(field, 0)
        self.put("wUpdateSpritesEnabled", 1)
        for x, y in ((9, 3), (16, 3), (12, 1), (12, 7), (15, 16)):
            self.put("wXCoord", x)
            self.put("wYCoord", y)
            self.call("BillsSecretGardenTryPikachuSkim")
        self.put("wXCoord", 12)
        self.put("wYCoord", 6)
        for event in ("EVENT_GOT_BILLS_GARDEN_PIKACHU",
                      "EVENT_SAW_BILLS_GARDEN_PIKACHU_SKIM"):
            self.set_event(event)
            self.call("BillsSecretGardenTryPikachuSkim")
            self.set_event(event, False)
        self.assertEqual(started, [])

    def test_garden_skim_finishes_or_times_out_without_locking_controls(self):
        self.stub("PlayCry", "UpdateSprites", "DelayFrame")
        updates = []
        movement_flag = 1 << self.const("BIT_SCRIPTED_NPC_MOVEMENT")
        finish = False

        def update(_):
            updates.append(True)
            if finish:
                self.put("wStatusFlags5", self.get("wStatusFlags5") & ~movement_flag)

        self.gb.hook_register(*self.symbols["UpdateSprites"], update, None)
        for finish in (False, True):
            with self.subTest(finish=finish):
                updates.clear()
                self.set_event("EVENT_SAW_BILLS_GARDEN_PIKACHU_SKIM", False)
                self.put("wXCoord", 12)
                self.put("wYCoord", 6)
                self.put("wUpdateSpritesEnabled", 1)
                self.put("hSpriteIndex", 3)
                self.put("wMapSpriteData", self.const("RIGHT"))
                self.put("wSprite01StateData2MapY", 7)
                self.put("wSprite01StateData2MapX", 15)
                self.call("BillsSecretGardenTryPikachuSkim")
                self.assertEqual(len(updates), 2 if finish else 193)
                self.assertEqual(self.event_set("EVENT_SAW_BILLS_GARDEN_PIKACHU_SKIM"), finish)
                self.assertFalse(self.event_set("EVENT_GOT_BILLS_GARDEN_PIKACHU"))
                for field in ("wJoyIgnore", "wNPCNumScriptedSteps", "wSimulatedJoypadStatesIndex",
                              "wUnusedOverrideSimulatedJoypadStatesIndex",
                              "wSprite01StateData2WalkAnimationCounter"):
                    self.assertEqual(self.get(field), 0)
                self.assertEqual(self.get("wStatusFlags5") & movement_flag, 0)
                self.assertEqual(self.get("wSprite01StateData2MapY", 2), [7, 15])
                self.assertEqual(self.get("wSprite01StateData2MovementByte1"), self.const("STAY"))
                self.assertEqual(self.get("wMapSpriteData"), self.const("RIGHT"))
                self.assertEqual(self.get("hSpriteIndex"), 3)

    def test_garden_skim_crosses_water_and_returns_to_its_bank(self):
        movement = self.rom_bytes("BillsSecretGardenPikachuSkimMovement", 9)
        self.assertEqual(movement, [self.const("NPC_MOVEMENT_RIGHT")] * 4 +
                         [self.const("NPC_MOVEMENT_LEFT")] * 4 + [255])
        layout = self.rom_bytes("BillsSecretGarden_Blocks", 90)
        for x in range(12, 16):
            y = 3
            block = layout[y // 2 * 10 + x // 2]
            offset = block * 16 + (y % 2 * 2 + 1) * 4 + x % 2 * 2
            self.assertEqual(self.rom_bytes("Overworld_Block", 1, offset),
                             [0x32] if x == 12 else [0x14])  # Bank edge, then open water.

    def test_garden_moves_can_be_remembered(self):
        for species, dvs, received, eligible in (
                ("PIKACHU", [0xEA, 0xAA], True, True),
                ("RAICHU", [0xEA, 0xAA], True, True),
                ("PIKACHU", [0xEA, 0xAA], False, False),
                ("PIKACHU", [0xEA, 0xAB], True, False),
                ("EEVEE", [0xEA, 0xAA], True, False)):
            with self.subTest(species=species, dvs=dvs, received=received):
                self.set_event("EVENT_GOT_BILLS_GARDEN_PIKACHU", received)
                self.put("wLoadedMonSpecies", self.const(species))
                self.put("wLoadedMonLevel", 25)
                self.put("wLoadedMonDVs", dvs)
                self.put("wLoadedMonMoves", [0] * 4)
                self.call("BuildMoveReminderList")
                count = self.get("wItemList")
                moves = self.reminder_moves()
                self.assertEqual(self.const("SURF") in moves, eligible)
                self.assertEqual(self.const("THUNDERBOLT") in moves, eligible)
                self.assertLessEqual(count, 14)
                self.assertEqual(len(moves), len(set(moves)))
                self.assertEqual(self.gb.memory[self.address("wItemList") + count + 1], 255)
        self.set_event("EVENT_GOT_BILLS_GARDEN_PIKACHU")
        self.put("wLoadedMonSpecies", self.const("PIKACHU"))
        self.put("wLoadedMonDVs", [0xEA, 0xAA])
        self.put("wLoadedMonMoves", [self.const("SURF"), self.const("THUNDERBOLT"), 0, 0])
        self.call("BuildMoveReminderList")
        moves = self.reminder_moves()
        self.assertNotIn(self.const("SURF"), moves)
        self.assertNotIn(self.const("THUNDERBOLT"), moves)

    def test_healing_hp_boundaries(self):
        self.stub("DelayFrames", "PrintText", "EffectCallBattleCore", "UpdateHPBar2")
        for turn in (0, 1):
            mon = "wEnemyMon" if turn else "wBattleMon"
            other = "wBattleMon" if turn else "wEnemyMon"
            for move in ("RECOVER", "SOFTBOILED", "REST"):
                for current, maximum in ((45, 300), (89, 600), (1, 256), (1, 512),
                                         (44, 300), (46, 300), (299, 300), (300, 300),
                                         (255, 255), (256, 256), (100, 301)):
                    with self.subTest(turn=turn, move=move, hp=(current, maximum)):
                        self.put("hWhoseTurn", turn)
                        self.put("wEnemyMoveNum" if turn else "wPlayerMoveNum", self.const(move))
                        self.put_hp(mon + "HP", current)
                        self.put_hp(mon + "MaxHP", maximum)
                        self.put_hp(other + "HP", 77)
                        self.put(mon + "Status", 8)
                        self.call("HealEffect_")
                        healed = maximum if move == "REST" else min(maximum, current + maximum // 2)
                        self.assertEqual(self.hp(mon + "HP"), healed)
                        self.assertEqual(self.hp(other + "HP"), 77)
                        expected_status = 2 if move == "REST" and current < maximum else 8
                        self.assertEqual(self.get(mon + "Status"), expected_status)

    def test_substitute_requires_surviving_hp(self):
        self.stub("DelayFrames", "PrintText", "PlayCurrentMoveAnimation",
                  "AnimationSubstitute", "DrawHUDsAndHPBars")
        mask = 1 << self.const("HAS_SUBSTITUTE_UP")
        for turn in (0, 1):
            side = "Enemy" if turn else "Player"
            mon = "wEnemyMon" if turn else "wBattleMon"
            for maximum in (100, 101, 255, 256, 599, 703):
                cost = maximum // 4
                for current in (cost - 1, cost, cost + 1, maximum):
                    with self.subTest(turn=turn, hp=(current, maximum)):
                        self.put("hWhoseTurn", turn)
                        self.put_hp(mon + "HP", current)
                        self.put_hp(mon + "MaxHP", maximum)
                        self.put(f"w{side}BattleStatus2", 0)
                        self.call("SubstituteEffect_")
                        self.assertEqual(self.hp(mon + "HP"), current - cost if current > cost else current)
                        self.assertEqual(bool(self.get(f"w{side}BattleStatus2") & mask), current > cost)
                self.put_hp(mon + "HP", maximum)
                self.put(f"w{side}BattleStatus2", mask)
                self.put(f"w{side}SubstituteHP", 17)
                self.call("SubstituteEffect_")
                self.assertEqual(self.hp(mon + "HP"), maximum)
                self.assertEqual(self.get(f"w{side}SubstituteHP"), 17)

    def test_ai_combines_every_type_pair(self):
        matchups = {}
        types = set()
        for line in (ROOT / "data/types/type_matchups.asm").read_text().splitlines():
            if not line.strip().startswith("db "):
                continue
            fields = line.strip().removeprefix("db ").split(",")
            if len(fields) != 3:
                continue
            attack, defence, factor = (self.const(field.strip()) for field in fields)
            types.update((attack, defence))
            matchups[attack, defence] = Fraction(factor, 10)
        for attack, first, second in product(sorted(types), repeat=3):
            with self.subTest(attack=attack, first=first, second=second):
                expected = Fraction(10)
                for defence in {first, second}:
                    expected *= matchups.get((attack, defence), 1)
                self.put("wEnemyMoveType", attack)
                self.put("wBattleMonType", [first, second])
                self.call("AIGetTypeEffectiveness")
                self.assertEqual(self.get("wTypeEffectiveness"), int(expected))

    def test_ai_scores_damage_without_status_type_bonuses(self):
        cases = (
            (("POISON", "WATER"), ("AGILITY", "PSYCHIC_M", "THUNDER_WAVE", "THUNDERBOLT"), [10, 9, 10, 9]),
            (("GROUND", "ROCK"), ("AGILITY", "PSYCHIC_M", "THUNDER_WAVE", "THUNDERBOLT"), [10, 10, 10, 11]),
            (("WATER", "FLYING"), ("ICE_BEAM", "THUNDERBOLT", "THUNDER_WAVE", "AGILITY"), [10, 9, 10, 10]),
            (("WATER", "ICE"), ("EMBER", "THUNDERBOLT", "THUNDER_WAVE", "AGILITY"), [10, 9, 10, 10]),
        )
        for types, moves, expected in cases:
            with self.subTest(types=types, moves=moves):
                self.put("wBattleMonType", [self.const(kind) for kind in types])
                self.put("wEnemyMonMoves", [self.const(move) for move in moves])
                self.put("wBuffer", [10] * 4)
                self.call("AIMoveChoiceModification3")
                self.assertEqual(self.get("wBuffer", 4), expected)

    def test_transform_checks_the_target_on_both_turns(self):
        self.stub("PrintText", "EffectCallBattleCore", "PlayCurrentMoveAnimation",
                  "AnimationTransformMon", "HideSubstituteShowMonAnim", "ReshowSubstituteAnim")
        invulnerable = 1 << self.const("INVULNERABLE")
        transformed = 1 << self.const("TRANSFORMED")
        for turn, own_hidden, target_hidden in product((0, 1), repeat=3):
            with self.subTest(turn=turn, own_hidden=own_hidden, target_hidden=target_hidden):
                user = "wEnemyMon" if turn else "wBattleMon"
                target = "wBattleMon" if turn else "wEnemyMon"
                side = "Enemy" if turn else "Player"
                other_side = "Player" if turn else "Enemy"
                self.put("hWhoseTurn", turn)
                self.put(f"w{side}BattleStatus1", invulnerable if own_hidden else 0)
                self.put(f"w{other_side}BattleStatus1", invulnerable if target_hidden else 0)
                self.put(f"w{side}BattleStatus3", 0)
                self.put(f"w{other_side}BattleStatus3", 0)
                self.put(user + "Species", self.const("DITTO"))
                self.put(target + "Species", self.const("PIKACHU"))
                self.put_hp(user + "HP", 37)
                self.put_hp(user + "MaxHP", 80)
                self.put(user + "Moves", [self.const("QUICK_ATTACK"), 0, 0, 0])
                self.put(target + "Moves", [self.const("SURF"), self.const("THUNDERBOLT"), 0, 0])
                self.call("TransformEffect_")
                self.assertEqual(bool(self.get(f"w{side}BattleStatus3") & transformed), not target_hidden)
                self.assertEqual(self.get(f"w{other_side}BattleStatus3"), 0)
                self.assertEqual(self.get(user + "Species"), self.const("DITTO" if target_hidden else "PIKACHU"))
                self.assertEqual(self.hp(user + "HP"), 37)
                self.assertEqual(self.hp(user + "MaxHP"), 80)
                if not target_hidden:
                    self.assertEqual(self.get(user + "Moves", 4), self.get(target + "Moves", 4))
                    self.assertEqual(self.get(user + "PP", 4), [5, 5, 0, 0])

    def test_deserter_uniform_visibility_and_save_overlap(self):
        self.stub("UpdateSprites")
        self.put("wCurMap", self.const("UNDERGROUND_PATH_WEST_EAST"))
        self.call("InitializeToggleableObjectsFlags")
        self.assertTrue(self.object_hidden("TOGGLE_UNDERGROUND_PATH_DISCARDED_UNIFORM"))
        self.call("MarkTownVisitedAndLoadToggleableObjects")
        self.assertEqual(self.get("wToggleableObjectList", 5),
                         [1, self.const("TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER"),
                          2, self.const("TOGGLE_UNDERGROUND_PATH_DISCARDED_UNIFORM"), 255])
        for hideout, silph, defeated in product((False, True), repeat=3):
            for x, y in ((33, 1), (34, 1), (34, 2)):
                with self.subTest(hideout=hideout, silph=silph, defeated=defeated, position=(x, y)):
                    self.set_event("EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI", hideout)
                    self.set_event("EVENT_BEAT_SILPH_CO_GIOVANNI", silph)
                    self.set_event("EVENT_BEAT_UNDERGROUND_PATH_ROCKET_DESERTER", defeated)
                    self.put("wXCoord", x)
                    self.put("wYCoord", y)
                    self.put("wCurrentMapScriptFlags", 1 << self.const("BIT_CUR_MAP_LOADED_1"))
                    self.call("UndergroundPathWestEastUpdateRocketDeserter")
                    overlap = (x, y) == (34, 1)
                    self.assertEqual(self.object_hidden("TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER"),
                                     overlap or defeated or silph or not hideout)
                    self.assertEqual(self.object_hidden("TOGGLE_UNDERGROUND_PATH_DISCARDED_UNIFORM"),
                                     overlap or not defeated)

    def test_deserter_leaves_uniform_during_flash_only_after_victory(self):
        self.stub("UpdateSprites", "EndTrainerBattle", "DisplayTextID", "PlaySound",
                  "GBFadeOutToWhite", "GBFadeInFromWhite", "Delay3", "WaitForSoundToFinish", "PrintText")
        flashes = []

        def record_flash(phase):
            flashes.append((phase, self.object_hidden("TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER"),
                            self.object_hidden("TOGGLE_UNDERGROUND_PATH_DISCARDED_UNIFORM")))

        for name, phase in (("GBFadeOutToWhite", "out"), ("GBFadeInFromWhite", "in")):
            bank, address = self.symbols[name]
            self.gb.hook_register(bank, address, record_flash, phase)
        for lost in (True, False):
            with self.subTest(lost=lost):
                flashes.clear()
                self.call("InitializeToggleableObjectsFlags")
                self.put("wToggleableObjectIndex", self.const("TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER"))
                self.call("ShowObject")
                self.put("wIsInBattle", 255 if lost else 0)
                self.put("wJoyIgnore", 255)
                self.put("wUndergroundPathWestEastCurScript", 2)
                self.put("wCurMapScript", 2)
                for field, value in (("StateData2MapY", 7), ("StateData2MapX", 38),
                                     ("StateData1YPixels", 60), ("StateData1XPixels", 64)):
                    self.put("wSprite01" + field, value)
                    self.put("wSprite02" + field, 0)
                self.call("UndergroundPathWestEastRocketDeserterPostBattleScript")
                self.assertEqual(self.get("wJoyIgnore"), 0)
                self.assertEqual(self.get("wUndergroundPathWestEastCurScript"), 0)
                self.assertEqual(self.get("wCurMapScript"), 0)
                if lost:
                    self.assertEqual(flashes, [])
                    self.assertFalse(self.object_hidden("TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER"))
                    self.assertTrue(self.object_hidden("TOGGLE_UNDERGROUND_PATH_DISCARDED_UNIFORM"))
                else:
                    self.assertEqual(flashes, [("out", False, True), ("in", True, False)])
                    for field in ("StateData2MapY", "StateData2MapX", "StateData1YPixels", "StateData1XPixels"):
                        self.assertEqual(self.get("wSprite02" + field), self.get("wSprite01" + field))


    def test_league_reopens_only_uncaught_mew_before_saving(self):
        self.stub("Delay3", "HallOfFamePC", "SaveGameData", "DelayFrames",
                  "WaitForTextScrollButtonPress", "Init")
        states_at_save = []
        self.gb.hook_register(*self.symbols["SaveGameData"],
                              lambda _: states_at_save.append(self.event_set("EVENT_BEAT_VERMILION_DOCK_MEW")), None)
        dex_bit = self.const("DEX_MEW") - 1
        dex_address = self.address("wPokedexOwned") + dex_bit // 8
        for completed, owned, truck_moved in product((False, True), repeat=3):
            with self.subTest(completed=completed, owned=owned, truck_moved=truck_moved):
                states_at_save.clear()
                self.set_event("EVENT_BEAT_VERMILION_DOCK_MEW", completed)
                self.set_event("EVENT_MOVED_VERMILION_DOCK_TRUCK", truck_moved)
                self.gb.memory[dex_address] = (1 << (dex_bit % 8)) if owned else 0
                self.put("wNumHoFTeams", 50)
                self.call("HallOfFameResetEventsAndSaveScript")
                self.assertEqual(states_at_save, [completed and owned])
                self.assertEqual(self.event_set("EVENT_BEAT_VERMILION_DOCK_MEW"), completed and owned)
                self.assertEqual(self.event_set("EVENT_MOVED_VERMILION_DOCK_TRUCK"), truck_moved)
                self.assertEqual(bool(self.gb.memory[dex_address] & (1 << (dex_bit % 8))), owned)

    def test_scripted_wild_battle_outcomes(self):
        self.stub("PrintText", "UpdateSprites", "ReplaceTileBlock")
        encounters = (
            ("VermilionDockMewPostBattleScript", "EVENT_BEAT_VERMILION_DOCK_MEW", "wVermilionDockCurScript"),
            ("LavenderTownWhiteHandPostBattleScript", "EVENT_BEAT_LAVENDER_WHITE_HAND", "wLavenderTownCurScript"),
            ("PokemonMansionB1FDittoPostBattleScript", "EVENT_BEAT_MANSION_DITTO", "wPokemonMansionB1FCurScript"),
            ("SeafoamIslandsB4FGyaradosPostBattleScript", "EVENT_BEAT_SEAFOAM_WHIRLPOOL_GYARADOS", "wSeafoamIslandsB4FCurScript"),
            ("FuchsiaCityRhyhornPostBattleScript", "EVENT_BEAT_FUCHSIA_ESCAPED_RHYHORN", "wFuchsiaCityCurScript"),
        )
        outcomes = (
            ("capture", 0, 1, 1, 0, True),
            ("defeat", 0, 0, 0, 0, True),
            ("run", 0, 2, 0, 1, False),
            ("unresolved", 0, 2, 0, 0, False),
            ("blackout", 255, 1, 0, 0, False),
            ("blackout_with_stale_capture", 255, 1, 1, 0, False),
            ("escape_with_stale_win", 0, 0, 0, 1, False),
        )
        for routine, event, script in encounters:
            for outcome, battle, result, captured, escaped, completed in outcomes:
                with self.subTest(encounter=routine, outcome=outcome):
                    self.set_event(event, False)
                    self.put("wIsInBattle", battle)
                    self.put("wBattleResult", result)
                    self.put("wBattleWasCaptured", captured)
                    self.put("wBattleWasEscaped", escaped)
                    self.put("wJoyIgnore", 255)
                    self.put(script, 1)
                    self.put("wCurMapScript", 1)
                    self.call(routine)
                    self.assertEqual(self.event_set(event), completed)
                    self.assertEqual(self.get("wJoyIgnore"), 0)
                    self.assertEqual(self.get(script), 0)
                    self.assertEqual(self.get("wCurMapScript"), 0)
                    if routine == "PokemonMansionB1FDittoPostBattleScript":
                        self.assertEqual(self.get("wNewTileBlockID"), 0x0E if completed else 0x77)

    def test_garden_gift_full_party_and_full_box(self):
        self.stub("EnableAutoTextBoxDrawing", "PrintText", "PlayCry", "WaitForSoundToFinish",
                  "AskName", "UpdateSprites", "TextScriptEnd", "WaitForTextScrollButtonPress")
        for party, box in ((5, 0), (6, 0), (6, 19), (6, 20)):
            with self.subTest(party=party, box=box):
                self.set_event("EVENT_GOT_BILLS_GARDEN_PIKACHU", False)
                self.put("wPartyCount", party)
                self.put("wBoxCount", box)
                self.put("wBoxSpecies", [self.const("EEVEE")] * box + [255])
                self.put("wBoxMon1", [0xA5] * self.const("BOXMON_STRUCT_LENGTH"))
                self.put("wPartyMon1", [0x5A] * self.const("PARTYMON_STRUCT_LENGTH"))
                self.put("wPokedexOwned", [0] * 19)
                self.put("wPlayerName", [0x80] * 7 + [0x50])
                self.put("wCurrentMapScriptFlags", 1 << self.const("BIT_CUR_MAP_LOADED_1"))
                self.call("BillsSecretGardenLoadMap")
                self.call("BillsSecretGardenPikachuText", offset=1)
                success = party < 6 or box < 20
                self.assertEqual(self.event_set("EVENT_GOT_BILLS_GARDEN_PIKACHU"), success)
                self.assertEqual(self.get("wPartyCount"), party + int(party < 6))
                self.assertEqual(self.get("wBoxCount"), box + int(party == 6 and success))
                self.assertEqual(self.get("wPartyMon1", self.const("PARTYMON_STRUCT_LENGTH")),
                                 [0x5A] * self.const("PARTYMON_STRUCT_LENGTH"))
                dex_bit = self.const("DEX_PIKACHU") - 1
                self.assertEqual(bool(self.gb.memory[self.address("wPokedexOwned") + dex_bit // 8]
                                      & (1 << (dex_bit % 8))), success)
                if success:
                    mon = f"wPartyMon{party + 1}" if party < 6 else "wBoxMon1"
                    self.assertEqual(self.get(mon + "Moves", 4), [self.const(move) for move in
                                     ("THUNDERBOLT", "SURF", "THUNDER_WAVE", "QUICK_ATTACK")])
                    self.assertEqual(self.get(mon + "PP", 4), [15, 15, 20, 30])
                if party == 6 and box == 19:
                    self.assertEqual(self.get("wBoxMon2", self.const("BOXMON_STRUCT_LENGTH")),
                                     [0xA5] * self.const("BOXMON_STRUCT_LENGTH"))
                if not success:
                    self.assertEqual(self.get("wBoxMon1", self.const("BOXMON_STRUCT_LENGTH")),
                                     [0xA5] * self.const("BOXMON_STRUCT_LENGTH"))
                self.put("wCurrentMapScriptFlags", 1 << self.const("BIT_CUR_MAP_LOADED_1"))
                self.call("BillsSecretGardenLoadMap")
                self.assertEqual(self.object_hidden("TOGGLE_BILLS_SECRET_GARDEN_PIKACHU"), success)
                if not success:
                    self.put("wBoxCount", 19)
                    self.call("BillsSecretGardenPikachuText", offset=1)
                    self.assertTrue(self.event_set("EVENT_GOT_BILLS_GARDEN_PIKACHU"))
                    self.assertEqual(self.get("wBoxCount"), 20)

    def test_mew_truck_retry_requires_a_new_league_win(self):
        self.stub("PrintText", "PlayCry", "WaitForSoundToFinish", "TextScriptEnd")
        self.set_event("EVENT_MOVED_VERMILION_DOCK_TRUCK")
        self.put("wElite4Flags", 1 << self.const("BIT_BEAT_ELITE_4"))
        self.put("wIsInBattle", 0)
        self.put("wBattleResult", 0)
        self.call("VermilionDockMewPostBattleScript")
        self.put("wCurOpponent", 0)
        self.call("VermilionDockTruckText", offset=1)
        self.assertEqual(self.get("wCurOpponent"), 0)
        self.call("HallOfFameReopenMewEncounter")
        self.call("VermilionDockTruckText", offset=1)
        self.assertEqual(self.get("wCurOpponent"), self.const("MEW"))
        self.assertEqual(self.get("wCurEnemyLevel"), 30)
        self.assertTrue(self.event_set("EVENT_MOVED_VERMILION_DOCK_TRUCK"))

    def test_moonfall_full_bag_can_retry_without_duplicate_reward(self):
        self.stub("PrintText", "TextScriptEnd", "GBFadeOutToWhite", "GBFadeInFromWhite",
                  "MtMoon1FShowMoonfallClefairy", "MtMoon1FHideMoonfallClefairy",
                  "MtMoon1FAnimateMoonfallDance", "MtMoon1FRetreatMoonfallClefairy",
                  "PlayCry", "WaitForSoundToFinish")
        dances = []
        self.gb.hook_register(*self.symbols["MtMoon1FAnimateMoonfallDance"],
                              lambda _: dances.append(True), None)
        self.set_event("EVENT_BEAT_MT_MOON_EXIT_SUPER_NERD")
        index = self.const("TOGGLE_MT_MOON_1F_ITEM_2")
        self.gb.memory[self.address("wToggleableObjectFlags") + index // 8] |= 1 << (index % 8)
        self.put("wNumBagItems", 20)
        items = [item for item in range(1, 22) if item != self.const("MOON_STONE")][:20]
        self.put("wBagItems", [value for item in items for value in (item, 1)] + [255])
        before = self.get("wBagItems", 41)
        self.call("MtMoon1FMoonfallSiteText", offset=1)
        self.assertFalse(self.event_set("EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY"))
        self.assertTrue(self.event_set("EVENT_SAW_MT_MOON_MOONFALL_DANCE"))
        self.assertEqual(self.get("wBagItems", 41), before)
        self.assertEqual(self.get("wJoyIgnore"), 0)
        self.put("wNumBagItems", 0)
        self.put("wBagItems", 255)
        self.call("MtMoon1FMoonfallSiteText", offset=1)
        self.assertTrue(self.event_set("EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY"))
        self.assertEqual(self.get("wNumBagItems"), 1)
        self.assertEqual(self.get("wBagItems", 3), [self.const("MOON_STONE"), 1, 255])
        self.assertEqual(dances, [True])
        # Saves from before the separate dance flag already own their reward.
        self.set_event("EVENT_SAW_MT_MOON_MOONFALL_DANCE", False)
        self.call("MtMoon1FMoonfallSiteText", offset=1)
        self.assertEqual(self.get("wBagItems", 3), [self.const("MOON_STONE"), 1, 255])
        self.assertEqual(dances, [True])

    def test_scene_movement_restores_text_and_clears_scripted_steps(self):
        self.stub("UpdateSprites", "DelayFrame")
        frames = []
        outcome = "timeout"
        def update(_):
            frames.append(True)
            if outcome == "finished":
                self.put("wStatusFlags5", 0)
        self.gb.hook_register(*self.symbols["UpdateSprites"], update, None)
        for outcome in ("finished", "offscreen", "timeout"):
            frames.clear()
            self.put("wFontLoaded", 0xA5)
            self.put("hSpriteIndex", 14)
            self.put("wStatusFlags5", 1 << self.const("BIT_SCRIPTED_NPC_MOVEMENT"))
            self.put("wSprite14StateData1ImageIndex", 255 if outcome == "offscreen" else 0)
            self.put("wSprite14StateData2MovementByte1", 0)
            self.put("wSprite14StateData2WalkAnimationCounter", 8)
            self.call("WaitForSceneSpriteMovement")
            self.assertEqual(len(frames), 192 if outcome == "timeout" else 1)
            self.assertEqual(self.get("wFontLoaded"), 0xA5)
            self.assertEqual(self.get("hSpriteIndex"), 14)
            self.assertEqual(self.get("wStatusFlags5"), 0)
            self.assertEqual(self.get("wSprite14StateData2MovementByte1"), self.const("STAY"))
            for name in ("wNPCNumScriptedSteps", "wSimulatedJoypadStatesIndex",
                         "wUnusedOverrideSimulatedJoypadStatesIndex", "wSprite14StateData2WalkAnimationCounter"):
                self.assertEqual(self.get(name), 0)

    def test_moonfall_dancers_circle_without_crossing_player_approaches(self):
        positions = {14: (5, 2), 15: (4, 3)}
        data = self.rom_bytes("MtMoon1FAnimateMoonfallDance.Steps", 25)
        bank = self.symbols["MtMoon1FAnimateMoonfallDance"][0]
        vectors = {self.const("NPC_MOVEMENT_UP"): (0, -1), self.const("NPC_MOVEMENT_DOWN"): (0, 1),
                   self.const("NPC_MOVEMENT_LEFT"): (-1, 0), self.const("NPC_MOVEMENT_RIGHT"): (1, 0)}
        for i in range(0, 24, 3):
            sprite, lo, hi = data[i:i + 3]
            dx, dy = vectors[self.gb.memory[bank, lo | hi << 8]]
            x, y = positions[sprite]
            positions[sprite] = (x + dx, y + dy)
            self.assertNotEqual(positions[14], positions[15])
            self.assertNotIn(positions[sprite], {(1, 2), (3, 2), (2, 1), (2, 3)})
        self.assertEqual(positions, {14: (5, 2), 15: (4, 3)})

    def test_moonfall_movement_leaves_dialogue_buttons_available(self):
        self.stub("WaitForSceneSpriteMovement", "DelayFrames", "PlayCry", "WaitForSoundToFinish")
        for name in ("MtMoon1FAnimateMoonfallDance", "MtMoon1FRetreatMoonfallClefairy"):
            self.put("hSpriteIndex", 16)
            self.call(name)
            self.assertEqual(self.get("hSpriteIndex"), 16)
            self.assertEqual(self.get("wJoyIgnore"), 0xF0)

    def test_seafoam_whirlpool_visibility_and_animation(self):
        self.put("wCurMap", self.const("SEAFOAM_ISLANDS_B4F"))
        self.call("MarkTownVisitedAndLoadToggleableObjects")
        for completed, overlap in product((False, True), repeat=2):
            self.set_event("EVENT_BEAT_SEAFOAM_WHIRLPOOL_GYARADOS", completed)
            self.put("wXCoord", 23)
            self.put("wYCoord", 6 if overlap else 7)
            self.put("hCurrentSpriteOffset", self.const("SEAFOAMISLANDSB4F_WHIRLPOOL") * 16)
            self.call("IsObjectHidden")
            self.assertEqual(bool(self.get("hIsToggleableObjectOff")), completed or overlap)
        self.stub("CopyVideoData")
        copies = []
        self.gb.hook_register(*self.symbols["CopyVideoData"],
                              lambda _: copies.append((self.gb.register_file.D * 256 + self.gb.register_file.E,
                                                       self.gb.register_file.HL,
                                                       self.gb.register_file.B * 256 + self.gb.register_file.C)), None)
        self.set_event("EVENT_BEAT_SEAFOAM_WHIRLPOOL_GYARADOS", False)
        self.put("wSprite04StateData2ImageBaseOffset", 12)
        self.put("wSprite04StateData1ImageIndex", 0xB0)
        for frame in (255, 7, 15, 23):
            self.put("wSprite04StateData1IntraAnimFrameCounter", frame)
            self.call("SeafoamIslandsB4FAnimateWhirlpool")
        bank, address = self.symbols["WhirlpoolSprite"]
        self.assertEqual(copies, [(address + i * 64, 0x87C0, bank * 256 + 4) for i in range(4)])
        self.set_event("EVENT_BEAT_SEAFOAM_WHIRLPOOL_GYARADOS")
        self.call("SeafoamIslandsB4FAnimateWhirlpool")
        self.assertEqual(len(copies), 4)

    def test_seafoam_whirlpool_fishing_target_and_completion_gate(self):
        self.put("wCurMap", self.const("SEAFOAM_ISLANDS_B4F"))
        self.put("wSpritePlayerStateData1FacingDirection", 4)
        for completed, position in product((False, True), ((23, 7), (22, 7), (23, 8))):
            self.set_event("EVENT_BEAT_SEAFOAM_WHIRLPOOL_GYARADOS", completed)
            self.put("wXCoord", position[0])
            self.put("wYCoord", position[1])
            self.put("wSeafoamIslandsB4FCurScript", 0)
            self.call("CheckSeafoamWhirlpoolFishingSpot")
            expected = position == (23, 7) and not completed
            self.assertEqual(bool(self.gb.register_file.F & 0x10), expected)
            self.assertEqual(bool(self.get("wSeafoamIslandsB4FCurScript")), expected)

    def test_legendary_visitors_depart_and_leave_original_encounters_untouched(self):
        self.stub("PrintText", "PlayCry", "WaitForSoundToFinish", "DelayFrames", "UpdateSprites",
                  "WaitForSceneSpriteMovement")
        cases = (("Route10ZapdosPostBattleScript", "wRoute10CurScript", 7, "ZAPDOS", "TOGGLE_ROUTE_10_VISITING_ZAPDOS"),
                 ("Route20ArticunoPostBattleScript", "wRoute20CurScript", 11, "ARTICUNO", "TOGGLE_ROUTE_20_VISITING_ARTICUNO"),
                 ("CinnabarMoltresPostBattleScript", "wCinnabarIslandCurScript", 3, "MOLTRES", "TOGGLE_CINNABAR_VISITING_MOLTRES"))
        moves = []
        self.gb.hook_register(*self.symbols["MoveSprite"],
                              lambda _: moves.append(self.get("hSpriteIndex")), None)
        for routine, script, sprite, species, toggle in cases:
            for blackout in (False, True):
                moves.clear()
                self.put("wIsInBattle", 255 if blackout else 0)
                self.put("wJoyIgnore", 255)
                self.put("wCurMapScript", 3)
                self.put(script, 3)
                flags = self.get("wEventFlags", 320)
                self.call(routine)
                self.assertEqual(moves, [] if blackout else [sprite])
                self.assertEqual(self.get("wEventFlags", 320), flags)
                if not blackout:
                    self.assertTrue(self.object_hidden(toggle))
                    self.assertEqual(self.get("wNPCMovementDirections", 7),
                                     [self.const("NPC_MOVEMENT_UP")] * 6 + [255])
                self.assertEqual(self.get(script), 0)
                self.assertEqual(self.get("wCurMapScript"), 0)
                self.assertEqual(self.get("wJoyIgnore"), 0)

    def test_legendary_departure_effects_restore_palette_and_camera(self):
        self.stub("DelayFrames")
        for species in ("ARTICUNO", "ZAPDOS", "MOLTRES"):
            self.put("hSCX", 13)
            self.gb.memory[0xFF47] = 0xE4
            self.call("LegendaryVisitorDepartureEffect", A=self.const(species))
            self.assertEqual(self.get("hSCX"), 13)
            self.assertEqual(self.gb.memory[0xFF47], 0xE4)

    def test_copycat_rematches_preserve_victory_and_restore_sprite(self):
        self.record_dialogue()
        self.stub("YesNoChoice", "PlaySound", "WaitForSoundToFinish", "PlayTrainerMusic",
                  "ReloadMapSpriteTilePatterns")
        self.set_event("EVENT_GOT_TM31")
        self.put("wMapSpriteExtraData", [self.const("OPP_COPYCAT"), 1])
        for previous_win, accept, blackout in product((False, True), repeat=3):
            self.set_event("EVENT_BEAT_COPYCAT", previous_win)
            self.put("wCurrentMenuItem", 0 if accept else 1)
            self.put("wCopycatsHouse2FCurScript", 0)
            self.put("wCurMapScript", 0)
            self.put("wSprite01StateData1PictureID", self.const("SPRITE_BRUNETTE_GIRL"))
            self.call("CopycatsHouse2FCopycatText", offset=1)
            self.assertEqual(self.event_set("EVENT_BEAT_COPYCAT"), previous_win)
            self.assertTrue(self.event_set("EVENT_GOT_TM31"))
            self.assertEqual(self.get("wCopycatsHouse2FCurScript"), 2 if accept else 0)
            self.assertEqual(self.get("wSprite01StateData1PictureID"),
                             self.const("SPRITE_RED" if accept else "SPRITE_BRUNETTE_GIRL"))
            if accept:
                self.assertEqual(self.get("wCurOpponent"), self.const("OPP_COPYCAT"))
                self.assertEqual(self.get("wTrainerNo"), 1)
                self.put("wIsInBattle", 255 if blackout else 0)
                self.call("CopycatsHouse2FEndBattleScript")
                self.assertEqual(self.event_set("EVENT_BEAT_COPYCAT"), previous_win or not blackout)
                self.assertEqual(self.get("wCopycatsHouse2FCurScript"), 0)
                self.assertEqual(self.get("wCurMapScript"), 0)
                self.assertEqual(self.get("wJoyIgnore"), 0)
                self.assertEqual(self.get("wSprite01StateData1PictureID"),
                                 self.const("SPRITE_BRUNETTE_GIRL"))

    def test_copycat_tm_full_bag_retry_and_rematch_do_not_duplicate_reward(self):
        self.record_dialogue()
        self.stub("YesNoChoice")
        self.gb.hook_register(*self.symbols["YesNoChoice"],
                              lambda _: self.put("wCurrentMenuItem", 1), None)
        self.put("wCurrentMenuItem", 1)
        self.put("wNumBagItems", 20)
        self.put("wBagItems", [self.const("POKE_DOLL"), 1] +
                 [self.const("POTION"), 99] * 19 + [255])
        self.call("CopycatsHouse2FCopycatText", offset=1)
        self.assertFalse(self.event_set("EVENT_GOT_TM31"))
        self.assertEqual(self.get("wBagItems", 2), [self.const("POKE_DOLL"), 1])
        self.put("wNumBagItems", 1)
        self.put("wBagItems", [self.const("POKE_DOLL"), 1, 255])
        self.call("CopycatsHouse2FCopycatText", offset=1)
        self.assertTrue(self.event_set("EVENT_GOT_TM31"))
        self.assertEqual(self.get("wNumBagItems"), 1)
        self.assertEqual(self.get("wBagItems", 3), [self.const("TM_MIMIC"), 1, 255])
        for won in (False, True):
            self.set_event("EVENT_BEAT_COPYCAT", won)
            self.call("CopycatsHouse2FCopycatText", offset=1)
            self.assertEqual(self.get("wBagItems", 3), [self.const("TM_MIMIC"), 1, 255])

    def test_copycat_matches_the_current_first_conscious_pokemon(self):
        self.stub("AddPartyMon", "ReadTrainer.FinishUp")
        opponents = []
        self.gb.hook_register(*self.symbols["AddPartyMon"],
                              lambda _: opponents.append((self.get("wCurPartySpecies"),
                                                           self.get("wCurEnemyLevel"))), None)
        self.put("wCurOpponent", self.const("OPP_COPYCAT"))
        self.put("wTrainerNo", 1)
        self.put("wPartyCount", 2)
        for first_hp, first_level, second_level in ((30, 18, 65), (30, 42, 65), (0, 42, 65)):
            opponents.clear()
            self.put_hp("wPartyMon1HP", first_hp)
            self.put_hp("wPartyMon2HP", 30)
            self.put("wPartyMon1Level", first_level)
            self.put("wPartyMon2Level", second_level)
            self.call("ReadTrainer")
            self.assertEqual(opponents, [(self.const("DITTO"), first_level if first_hp else second_level)])

    def test_snorlax_dream_preserves_both_routes_and_the_sleeping_encounters(self):
        printed = self.record_dialogue()
        self.stub("PlaySound", "GBFadeOutToWhite", "GBFadeInFromWhite", "Delay3",
                  "DrawSnorlaxDreamBanquet", "AnimateSnorlaxDreamBanquet", "RunPaletteCommand",
                  "ReloadMapData", "ReloadMapSpriteTilePatterns", "RunDefaultPaletteCommand",
                  "PlayDefaultMusic")
        scenes = []
        self.gb.hook_register(*self.symbols["DrawSnorlaxDreamBanquet"],
                              lambda _: scenes.append(True), None)
        for route, lead, party_count in product((12, 16), ("DROWZEE", "HYPNO", "DITTO"), (0, 1)):
            printed.clear()
            scenes.clear()
            self.put("wCurMap", self.const(f"ROUTE_{route}"))
            self.put("wXCoord", 10)
            self.put("wYCoord", 63)
            self.put("wDestinationWarpID", 2)
            self.put("wPartyCount", party_count)
            self.put("wPartySpecies", self.const(lead))
            self.put("wPartyMonNicks", [0x83, 0x91, 0x84, 0x80, 0x8C, 0x50] + [0x50] * 5)
            self.put("wUpdateSpritesEnabled", 1)
            self.put("hTileAnimations", 2)
            self.put("wJoyIgnore", 0xF0)
            party = self.get("wPartyDataStart", self.address("wPartyDataEnd") - self.address("wPartyDataStart"))
            flags = self.get("wEventFlags", 320)
            toggles = self.get("wToggleableObjectFlags", 32)
            self.call(f"Route{route}SnorlaxText", offset=1)
            dreaming = party_count == 1 and lead in ("DROWZEE", "HYPNO")
            self.assertEqual(scenes, [True] if dreaming else [])
            expected = ["SnorlaxDreamLinkText", "SnorlaxDreamText", "SnorlaxDreamEndedText"] if dreaming else [f"Route{route}SnorlaxText.SleepingText"]
            self.assertEqual(printed, [self.address(name) for name in expected])
            self.assertEqual(self.get("wCurMap"), self.const(f"ROUTE_{route}"))
            self.assertEqual((self.get("wXCoord"), self.get("wYCoord"), self.get("wDestinationWarpID")), (10, 63, 2))
            self.assertEqual(self.get("wUpdateSpritesEnabled"), 1)
            self.assertEqual(self.get("hTileAnimations"), 2)
            self.assertEqual(self.get("wJoyIgnore"), 0xF0)
            self.assertEqual(self.get("wEventFlags", 320), flags)
            self.assertEqual(self.get("wToggleableObjectFlags", 32), toggles)
            self.assertEqual(self.get("wPartyDataStart", len(party)), party)

    def test_snorlax_banquet_uses_stock_graphics_and_bounded_falling_food(self):
        self.stub("CopyVideoData", "DelayFrames")
        copies = []
        self.gb.hook_register(*self.symbols["CopyVideoData"], lambda _: copies.append(
            (self.gb.register_file.B, self.gb.register_file.D * 256 + self.gb.register_file.E,
             self.gb.register_file.HL, self.gb.register_file.C)), None)
        self.put("wTileMap", [0x7F] * 360)
        self.gb.memory[self.address("wTileMap") + 360] = 0xA5
        self.call("DrawSnorlaxDreamBanquet")
        expected = (("RedsHouse1_GFX", 0, 0, 64), ("SnorlaxSprite", 0, 0x40, 4),
                    ("MoveAnimationTiles0", 0x4E, 0x44, 1))
        self.assertEqual(copies, [(self.symbols[name][0], self.address(name) + source * 16,
                                  self.address("vTileset") + dest * 16, count)
                                 for name, source, dest, count in expected])
        table = self.get("wTileMap", 360)[140:200]
        self.assertEqual(table, [0x27] * 20 + [0x2A] * 20 + [0x3A] * 20)
        frames = []
        self.gb.hook_register(*self.symbols["DelayFrames"],
                              lambda _: frames.append(self.get("wTileMap", 360)), None)
        self.call("AnimateSnorlaxDreamBanquet")
        self.assertEqual(len(frames), 24)
        for cycle in range(3):
            for row, frame in enumerate(frames[cycle * 8 + 1:cycle * 8 + 8]):
                food = [index for index, tile in enumerate(frame) if tile == 0x44]
                self.assertEqual(food, [row * 20 + x for x in (3, 9, 15)])
                self.assertEqual(frame[140:200], table)
        self.assertEqual(self.gb.memory[self.address("wTileMap") + 360], 0xA5)

    def test_rhyhorn_reentry_and_player_overlap(self):
        self.stub("UpdateSprites")
        self.set_event("EVENT_FUCHSIA_RHYHORN_ESCAPED")
        self.set_event("EVENT_SAW_FUCHSIA_RHYHORN_ESCAPE")
        for completed in (False, True):
            for x, y in ((17, 8), (18, 8), (18, 10)):
                with self.subTest(completed=completed, position=(x, y)):
                    self.set_event("EVENT_BEAT_FUCHSIA_ESCAPED_RHYHORN", completed)
                    self.put("wXCoord", x)
                    self.put("wYCoord", y)
                    self.put("wCurrentMapScriptFlags", 1 << self.const("BIT_CUR_MAP_LOADED_1"))
                    self.call("FuchsiaCityLoadRhyhornEscapeObjects")
                    hidden = completed or x == 18
                    self.assertEqual(self.object_hidden("TOGGLE_FUCHSIA_CITY_ESCAPED_RHYHORN"), hidden)
                    self.assertEqual(self.object_hidden("TOGGLE_FUCHSIA_CITY_CHASING_WARDEN"), hidden)


    def test_deserter_second_life_visibility_and_overlap(self):
        self.put("wCurMap", self.const("ROUTE_12"))
        self.call("MarkTownVisitedAndLoadToggleableObjects")
        original_toggles = self.get("wToggleableObjectList", 7)
        for deserter, silph in product((False, True), repeat=2):
            self.set_event("EVENT_BEAT_UNDERGROUND_PATH_ROCKET_DESERTER", deserter)
            self.set_event("EVENT_BEAT_SILPH_CO_GIOVANNI", silph)
            for x, y in ((12, 72), (13, 72), (12, 73), (13, 71)):
                for npc in ("ROUTE12_REFORMED_FISHER", "ROUTE12_RATICATE"):
                    with self.subTest(deserter=deserter, silph=silph, position=(x, y), npc=npc):
                        self.put("wXCoord", x)
                        self.put("wYCoord", y)
                        self.put("hCurrentSpriteOffset", self.const(npc) * 16)
                        self.call("IsObjectHidden")
                        self.assertEqual(bool(self.get("hIsToggleableObjectOff")),
                                         not (deserter and silph) or y == 72)
        self.assertEqual(self.get("wToggleableObjectList", 7), original_toggles)
        self.assertEqual(self.get("wCurOpponent"), 0)

    def test_pidgey_delivery_starts_from_either_saffron_npc_after_silph(self):
        printed = self.record_dialogue()
        self.stub("PlayCry", "WaitForSoundToFinish")
        girl = "SaffronPidgeyHouseBrunetteGirlText"
        bird = "SaffronPidgeyHousePidgeyText"
        owner = "VermilionPidgeyHouseYoungsterText"
        for npc in (girl, bird, owner):
            self.call(npc, offset=1)
            self.assertEqual(printed[-1], self.address(npc + ".OriginalText"))
            self.assertFalse(self.event_set("EVENT_STARTED_PIDGEY_DELIVERY"))
        self.call("Route6GateLostLetterText", offset=1)
        self.assertFalse(self.event_set("EVENT_FOUND_PIDGEY_LETTER"))
        self.set_event("EVENT_BEAT_SILPH_CO_GIOVANNI")
        self.call(owner, offset=1)
        self.assertEqual(printed[-1], self.address(owner + ".WorriedText"))
        for npc, dialogue in ((girl, ".ExhaustedText"), (bird, ".TiredText")):
            self.set_event("EVENT_STARTED_PIDGEY_DELIVERY", False)
            self.call(npc, offset=1)
            self.assertTrue(self.event_set("EVENT_STARTED_PIDGEY_DELIVERY"))
            self.assertEqual(printed[-1], self.address(npc + dialogue))
            self.call(girl, offset=1)
            self.assertEqual(printed[-1], self.address(girl + ".GateHintText"))
        self.assertEqual(self.get("wCurOpponent"), 0)

    def test_pidgey_rests_only_during_the_new_story(self):
        self.stub("EnableAutoTextBoxDrawing")
        for silph in (False, True):
            self.set_event("EVENT_BEAT_SILPH_CO_GIOVANNI", silph)
            self.put("wSprite02StateData2MovementByte1", self.const("WALK"))
            self.call("SaffronPidgeyHouse_Script")
            self.assertEqual(self.get("wSprite02StateData2MovementByte1"),
                             self.const("STAY" if silph else "WALK"))

    def test_pidgey_delivery_objects_follow_progress_on_reentry(self):
        for silph, started, found, delivered in product((False, True), repeat=4):
            for event, value in (("EVENT_BEAT_SILPH_CO_GIOVANNI", silph),
                                 ("EVENT_STARTED_PIDGEY_DELIVERY", started),
                                 ("EVENT_FOUND_PIDGEY_LETTER", found),
                                 ("EVENT_DELIVERED_PIDGEY_LETTER", delivered)):
                self.set_event(event, value)
            for map_name, npc, hidden in (
                    ("SAFFRON_PIDGEY_HOUSE", "SAFFRONPIDGEYHOUSE_PIDGEY", delivered),
                    ("VERMILION_PIDGEY_HOUSE", "VERMILIONPIDGEYHOUSE_PIDGEY", silph and not delivered),
                    ("ROUTE_6_GATE", "ROUTE6GATE_LOST_LETTER", not started or found)):
                with self.subTest(map=map_name, silph=silph, started=started, found=found, delivered=delivered):
                    self.put("wCurMap", self.const(map_name))
                    self.call("MarkTownVisitedAndLoadToggleableObjects")
                    self.put("hCurrentSpriteOffset", self.const(npc) * 16)
                    self.call("IsObjectHidden")
                    self.assertEqual(bool(self.get("hIsToggleableObjectOff")), hidden)
                    # Each household's owner and the gate guard keep their original visibility.
                    self.put("hCurrentSpriteOffset", 16)
                    self.call("IsObjectHidden")
                    self.assertEqual(self.get("hIsToggleableObjectOff"), 0)

    def test_pidgey_gate_guard_points_to_the_uncollected_letter(self):
        printed = self.record_dialogue()
        self.put("wStatusFlags1", 1 << self.const("BIT_GAVE_SAFFRON_GUARDS_DRINK"))
        for started, found in product((False, True), repeat=2):
            self.set_event("EVENT_STARTED_PIDGEY_DELIVERY", started)
            self.set_event("EVENT_FOUND_PIDGEY_LETTER", found)
            self.call("Route6GateGuardText", offset=1)
            expected = ("Route6GateGuardText.LetterHintText" if started and not found
                        else "SaffronGateGuardThanksForTheDrinkText")
            self.assertEqual(printed[-1], self.address(expected))
            self.assertEqual(self.get("wRoute6GateCurScript"), 0)

    def test_pidgey_delivery_full_bag_departure_and_reunion(self):
        printed = self.record_dialogue()
        self.stub("UpdateSprites", "PlayCry", "WaitForSoundToFinish",
                  "GBFadeOutToWhite", "GBFadeInFromWhite")
        flashes = []
        for name, phase in (("GBFadeOutToWhite", "out"), ("GBFadeInFromWhite", "in")):
            self.gb.hook_register(*self.symbols[name],
                                  lambda phase: flashes.append((phase, self.event_set("EVENT_DELIVERED_PIDGEY_LETTER"))), phase)
        girl = "SaffronPidgeyHouseBrunetteGirlText"
        owner = "VermilionPidgeyHouseYoungsterText"
        self.put("wNumBagItems", 20)
        self.put("wBagItems", [value for item in range(1, 21) for value in (item, 1)] + [255])
        full_bag = self.get("wBagItems", 41)
        self.set_event("EVENT_BEAT_SILPH_CO_GIOVANNI")
        self.call(girl, offset=1)
        self.call("Route6GateLostLetterText", offset=1)
        self.assertTrue(self.event_set("EVENT_FOUND_PIDGEY_LETTER"))
        printed.clear()
        self.call("Route6GateLostLetterText", offset=1)
        self.assertEqual(printed, [])
        self.call(girl, offset=1)
        self.assertEqual(flashes, [("out", False), ("in", True)])
        self.assertEqual(self.get("wBagItems", 41), full_bag)
        self.call(girl, offset=1)
        self.assertEqual(len(flashes), 2)
        self.assertEqual(printed[-1], self.address(girl + ".ReplyReminderText"))
        self.call(owner, offset=1)
        self.assertTrue(self.event_set("EVENT_REUNITED_COURIER_PIDGEY"))
        self.assertFalse(self.event_set("EVENT_GOT_PIDGEY_DELIVERY_PP_UP"))
        self.assertEqual(printed[-1], self.address(owner + ".BagFullText"))
        self.assertEqual(self.get("wBagItems", 41), full_bag)
        self.put("wNumBagItems", 0)
        self.put("wBagItems", 255)
        printed.clear()
        self.call(owner, offset=1)
        self.assertNotIn(self.address(owner + ".ReunionText"), printed)
        self.assertTrue(self.event_set("EVENT_GOT_PIDGEY_DELIVERY_PP_UP"))
        self.assertEqual(self.get("wBagItems", 3), [self.const("PP_UP"), 1, 255])
        self.call(owner, offset=1)
        self.assertEqual(self.get("wBagItems", 3), [self.const("PP_UP"), 1, 255])
        self.assertEqual(printed[-1], self.address(owner + ".AfterText"))
        self.call(girl, offset=1)
        self.assertEqual(printed[-1], self.address(girl + ".ReunitedText"))
        self.assertEqual(self.get("wJoyIgnore"), 0)
        self.assertEqual(self.get("wCurOpponent"), 0)

    def test_dialogue_width_token_accounting(self):
        self.assertEqual(line_width("#MON"), 7)
        self.assertEqual(line_width("<PLAYER> received"), 16)
        self.assertEqual(line_width("It's ready!"), 10)
        self.assertEqual(line_width("<PKMN>@"), 2)
        self.assertEqual(line_width("<RIVAL> " + "X" * 11), 19)

    def test_reward_encounter_and_rumour_dialogue_fits(self):
        self.assertEqual(dialogue_issues(), [])

    def test_pewter_rumour_only_when_moonfall_is_available(self):
        printed = self.record_dialogue()
        npc = "PewterCityCooltrainerFText"
        index = self.const("TOGGLE_MT_MOON_1F_ITEM_2")
        for nerd_beaten, stone_taken, complete in product((False, True), repeat=3):
            with self.subTest(nerd_beaten=nerd_beaten, stone_taken=stone_taken, complete=complete):
                printed.clear()
                self.set_event("EVENT_BEAT_MT_MOON_EXIT_SUPER_NERD", nerd_beaten)
                self.set_event("EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY", complete)
                self.gb.memory[self.address("wToggleableObjectFlags") + index // 8] = (1 << (index % 8)) if stone_taken else 0
                self.call(npc, offset=1)
                expected = "MoonfallRumourText" if nerd_beaten and stone_taken and not complete else "OriginalText"
                self.assertEqual(printed, [self.address(npc + "." + expected)])

    def test_celadon_rumour_matches_the_deserter_window(self):
        printed = self.record_dialogue()
        npc = "CeladonCityGramps2Text"
        for hideout, silph, deserter in product((False, True), repeat=3):
            with self.subTest(hideout=hideout, silph=silph, deserter=deserter):
                printed.clear()
                self.set_event("EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI", hideout)
                self.set_event("EVENT_BEAT_SILPH_CO_GIOVANNI", silph)
                self.set_event("EVENT_BEAT_UNDERGROUND_PATH_ROCKET_DESERTER", deserter)
                self.call(npc, offset=1)
                expected = "DeserterRumourText" if hideout and not silph and not deserter else "OriginalText"
                self.assertEqual(printed, [self.address(npc + "." + expected)])

    def test_vermilion_sailor_gives_one_current_lead(self):
        printed = self.record_dialogue()
        npc = "VermilionCitySailor2Text"
        dex_bit = self.const("DEX_MEW") - 1
        for departed, champion, caught, defeated, moved, sailor_beaten in product((False, True), repeat=6):
            with self.subTest(departed=departed, champion=champion, caught=caught,
                              defeated=defeated, moved=moved, sailor_beaten=sailor_beaten):
                printed.clear()
                self.set_event("EVENT_SS_ANNE_LEFT", departed)
                self.put("wElite4Flags", (1 << self.const("BIT_BEAT_ELITE_4")) if champion else 0)
                self.gb.memory[self.address("wPokedexOwned") + dex_bit // 8] = (1 << (dex_bit % 8)) if caught else 0
                self.set_event("EVENT_BEAT_VERMILION_DOCK_MEW", defeated)
                self.set_event("EVENT_MOVED_VERMILION_DOCK_TRUCK", moved)
                self.set_event("EVENT_BEAT_VERMILION_DOCK_GHOST_SAILOR", sailor_beaten)
                self.call(npc, offset=1)
                if not departed or not champion:
                    expected = "OriginalText"
                elif not caught:
                    expected = "MewRetryRumourText" if defeated else "MewReturnedRumourText" if moved else "TruckRumourText"
                else:
                    expected = "OriginalText" if sailor_beaten else "GhostSailorRumourText"
                self.assertEqual(printed, [self.address(npc + "." + expected)])


if __name__ == "__main__":
    GameplayTests.constants = read_constants()
    passed = True
    for path in sys.argv[1:] or ["pokered.gbc"]:
        GameplayTests.rom = Path(path).resolve()
        print(f"\nTesting {GameplayTests.rom.name}", flush=True)
        result = unittest.TextTestRunner(verbosity=2).run(
            unittest.defaultTestLoader.loadTestsFromTestCase(GameplayTests))
        passed &= result.wasSuccessful()
    sys.exit(0 if passed else 1)
