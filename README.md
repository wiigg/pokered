# Pokémon Red and Blue [![Build Status][ci-badge]][ci]

This is a disassembly of Pokémon Red and Blue.

This fork is a faithful enhancement of the original Pokémon Red: restoring
secrets and playground myths, strengthening battles, and adding thoughtful
quality-of-life improvements. The goal is to expand the adventure without
sanding away Gen I's strange, compact charm or turning it into a different
game.

Save compatibility is a core design constraint. Saves are intended to move in
both directions between this fork and an unmodified Pokémon Red cartridge, so
changes preserve the original save layout, Pokémon structures, and established
IDs.

## Roadmap

- [x] Make the “Mew under the truck” myth real using the [Vermilion Dock script](scripts/VermilionDock.asm#L1).
- [x] Add Professor Oak as a postgame superboss.
- [x] Make all 151 Pokémon obtainable on one cartridge, with former trade evolutions occurring at level 40.
- [x] Remix wild encounters so each area has a stronger identity and occasional exciting rare finds.
- [ ] Upgrade Gym Leaders, rivals, and the Elite Four with fuller, smarter teams.
- [ ] Add a small “Red+” package:
  - [x] Make TMs reusable.
  - [x] Hold B to run while walking.
  - [ ] Improve weak moves.
  - [ ] Add optional fixes for Focus Energy and Ghost versus Psychic.

To set up the repository, see [**INSTALL.md**](INSTALL.md).

[ci]: https://github.com/wiigg/pokered/actions
[ci-badge]: https://github.com/wiigg/pokered/actions/workflows/main.yml/badge.svg
