# Gameplay regression checks

Run `make check-gameplay PYTHON=/path/to/venv/bin/python` after installing
[requirements.txt](requirements.txt). CI runs the checks for Red, Blue and Blue
debug. PyBoy executes the built ROM's routines; symbols locate the current code
and RGBDS supplies constants. ROMs and save RAM are isolated in memory.

Coverage includes:

- Garden Pikachu's party and box gifts, full storage, moves/PP, preservation of
  existing boxed Pokémon, move recovery and visibility on map re-entry.
- Moonfall's full-bag failure, successful retry and one-time reward.
- Capture, defeat, escape, unresolved battle and blackout outcomes for Mew,
  White Hand, the Mansion Ditto, Seafoam Gyarados and escaped Fuchsia Rhyhorn.
- Mew's League reset before saving, including older completed encounters and
  previously caught Mew, with the moved truck preserved.
- Rhyhorn and Rocket-deserter re-entry, overlap protection, and the uniform swap
  during the departure flash.
- The Route 12 fisherman and Raticate require both the deserter battle and
  Silph's liberation, and stay clear of a player loaded onto either new spot.
- Progress-sensitive dialogue selection for the Pewter, Celadon and Vermilion
  rumour NPCs, including unavailable and completed mysteries.
- Healing boundaries, Substitute cost, Transform targeting and every attacking
  type against every defensive type pair for AI scoring.
- Quoted dialogue lines in the files listed in
  [dialogue_width.py](dialogue_width.py), counting character-map contractions and
  the maximum player/rival name lengths against the 18-tile text box.

Rendering, sound, name entry and button-wait routines are stubbed where needed.
The tests verify gameplay state and call ordering; visual timing, collision in
a fully loaded scene, and dynamic `text_ram`/numeric insertions still need
scene-specific tests or emulator playtesting. Add new dialogue files to the
width checker and new encounter outcomes to the regression suite as features
are introduced.
