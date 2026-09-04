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
                  "MtMoon1FAnimateMoonfallDance", "PlayCry", "WaitForSoundToFinish")
        self.set_event("EVENT_BEAT_MT_MOON_EXIT_SUPER_NERD")
        index = self.const("TOGGLE_MT_MOON_1F_ITEM_2")
        self.gb.memory[self.address("wToggleableObjectFlags") + index // 8] |= 1 << (index % 8)
        self.put("wNumBagItems", 20)
        items = [item for item in range(1, 22) if item != self.const("MOON_STONE")][:20]
        self.put("wBagItems", [value for item in items for value in (item, 1)] + [255])
        before = self.get("wBagItems", 41)
        self.call("MtMoon1FMoonfallSiteText", offset=1)
        self.assertFalse(self.event_set("EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY"))
        self.assertEqual(self.get("wBagItems", 41), before)
        self.assertEqual(self.get("wJoyIgnore"), 0)
        self.put("wNumBagItems", 0)
        self.put("wBagItems", 255)
        self.call("MtMoon1FMoonfallSiteText", offset=1)
        self.assertTrue(self.event_set("EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY"))
        self.assertEqual(self.get("wNumBagItems"), 1)
        self.assertEqual(self.get("wBagItems", 3), [self.const("MOON_STONE"), 1, 255])
        self.call("MtMoon1FMoonfallSiteText", offset=1)
        self.assertEqual(self.get("wBagItems", 3), [self.const("MOON_STONE"), 1, 255])

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


    def test_dialogue_width_token_accounting(self):
        self.assertEqual(line_width("#MON"), 7)
        self.assertEqual(line_width("<PLAYER> received"), 16)
        self.assertEqual(line_width("It's ready!"), 10)
        self.assertEqual(line_width("<PKMN>@"), 2)
        self.assertEqual(line_width("<RIVAL> " + "X" * 11), 19)

    def test_reward_encounter_and_rumour_dialogue_fits(self):
        self.assertEqual(dialogue_issues(), [])


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
