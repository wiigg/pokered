"""Check literal lines in the reward, encounter and rumour dialogue under test.

Uses the game's character tokens (including single-tile contractions) and the
longest player/rival names. Runtime text_ram/numeric insertions still need a
scene-specific check or playtest; this scanner checks the quoted lines.
"""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
DIALOGUE_FILES = (
    "BillsSecretGarden", "VermilionDock", "UndergroundPathRoute8", "LavenderTown",
    "MtMoon1F", "PokemonMansionB1F", "SeafoamIslandsB4F", "FuchsiaCity",
    "PewterCity", "CeladonCity", "VermilionCity", "Route12",
)
TOKENS = sorted(re.findall(r'^\s*charmap "([^"]+)",',
                          (ROOT / "constants/charmap.asm").read_text(), re.M), key=len, reverse=True)
WIDTHS = {"<PLAYER>": 7, "<RIVAL>": 7, "#": 4, "<PKMN>": 2, "<……>": 2,
          "<PC>": 2, "<TM>": 2, "<TRAINER>": 7, "<ROCKET>": 6,
          "<TARGET>": 16, "<USER>": 16}
LINE = re.compile(r'^\s*(?:text|line|cont|para)\s+"([^"]*)"')


def line_width(text):
    width = 0
    while text and not text.startswith("@"):
        token = next((token for token in TOKENS if text.startswith(token)), None)
        if token is None:
            raise ValueError(f"Unknown dialogue token: {text!r}")
        width += WIDTHS.get(token, 1)
        text = text[len(token):]
    return width


def dialogue_issues():
    issues = []
    for name in DIALOGUE_FILES:
        path = ROOT / "text" / f"{name}.asm"
        for number, line in enumerate(path.read_text().splitlines(), 1):
            match = LINE.match(line)
            if match:
                width = line_width(match[1])
                if width > 18:
                    issues.append(f"text/{name}.asm:{number}: {width}/18 tiles: {match[1]}")
    return issues
