# Gameplay regression checks

Run `make check-gameplay PYTHON=/path/to/venv/bin/python` after installing
[requirements.txt](requirements.txt). CI runs the checks for Red, Blue and Blue
debug. PyBoy executes the built ROM's routines; symbols locate the current code
and RGBDS supplies constants. ROMs and save RAM are isolated in memory.

Coverage includes:

- Garden arrival, its visible exit and the Route 25 return point against
  compiled collision data, plus the existing entrance-unlock requirement and
  an encounter-free walking route to the garden's landmarks and pond events.
- Garden Pikachu's party and box gifts, full storage, moves/PP, preservation of
  existing boxed Pokémon, move recovery and visibility on map re-entry.
- Pikachu's pond-crossing route, first-approach gates, one-time scene flag and
  input/position cleanup after either completed movement or a timeout.
- The garden's wandering Butterfree appears only after Pikachu joins, stays
  clear of an overlapping player, and offers a cry without a battle or reward.
- Moonfall's full-bag failure, successful retry without repeating the dance,
  and one-time reward.
- Seafoam's whirlpool visibility, old-save overlap, four-frame animation and
  precise fishing target before and after the encounter is completed.
- Capture, defeat, escape, unresolved battle and blackout outcomes for Mew,
  White Hand, the Mansion Ditto, Seafoam Gyarados and escaped Fuchsia Rhyhorn.
- Mew's League reset before saving, including older completed encounters and
  previously caught Mew, with the moved truck preserved.
- Rhyhorn and Rocket-deserter re-entry, overlap protection, and the uniform swap
  during the departure flash.
- The Route 12 fisherman and Raticate require both the deserter battle and
  Silph's liberation, and stay clear of a player loaded onto either new spot.
- Pidgey's delivery story: original household dialogue and movement before
  Silph, the resting courier afterwards, either opening conversation, the
  guard's clue, letter pickup and map re-entry, departure during a fade, reply
  delivery, and a full-bag reward retry without repeating the reunion or
  duplicating gifts.
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
