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

    def put_hp(self, name, value):
        self.put(name, list(value.to_bytes(2, "big")))

    def hp(self, name):
        return int.from_bytes(self.get(name, 2), "big")

    def stub(self, *names):
        for name in names:
            bank, address = self.symbols[name]
            self.gb.memory[bank, address] = 0xC9  # RET

    def call(self, name, **registers):
        bank, address = self.symbols[name]
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
