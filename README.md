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
IDs. Saving inside Bill's Secret Garden is disabled until the player returns to
an original location that an unmodified game can load safely.

## Roadmap

- [x] Make the “Mew under the truck” myth real using the [Vermilion Dock script](scripts/VermilionDock.asm#L1).
- [x] Make Lavender Town's [“white hand” rumour](scripts/LavenderTown.asm) real with a hidden Haunter encounter.
- [x] Set apart a solitary [memorial to Blue's missing Raticate](scripts/PokemonTower2F.asm) in Pokémon Tower.
- [x] Hint through a torn [Pokémon Mansion diary](text/PokemonMansionB1F.asm) that Ditto may be failed Mew clones.
- [x] Turn Celadon Hotel's [invisible PC](scripts/CeladonHotel.asm) into a Rocket shipment mystery ending in a hidden [Chief battle](scripts/CeladonChiefHouse.asm).
- [x] Make [Bill's Secret Garden](scripts/BillsSecretGarden.asm) real as a postgame Eevee-family secret, with a unique Surfing Pikachu and hints of discoveries still to come.
- [x] Add a [Clefairy Moonfall Ceremony](scripts/MtMoon1F.asm) at Mt. Moon's original Moon Stone landing site.
- [x] Give Mt. Moon's [Magikarp salesman](scripts/MtMoonPokecenter.asm) a “no refunds” challenge after discovering Gyarados's potential.
- [x] Add Professor Oak as a postgame superboss.
- [x] Give a completed 151-species Pokédex a proper epilogue and a framed bedroom diploma.
- [x] Add a repeatable [Trial of Three](scripts/FightingDojo.asm) gauntlet with no rest between battles.
- [x] Make all 151 Pokémon obtainable on one cartridge, with former trade evolutions occurring at level 40.
- [x] Remix wild encounters so each area has a stronger identity and occasional exciting rare finds.
- [x] Upgrade major trainers with fuller, smarter teams:
  - [x] Upgrade all eight Gym Leaders.
  - [x] Strengthen rival battles.
  - [x] Rebuild the Elite Four and Champion.
- [x] Add a small “Red+” package:
  - [x] Make TMs reusable.
  - [x] Hold B to run while walking.
  - [x] Improve overlooked moves such as Cut, Wing Attack, Vine Whip, Leech Life, and Rock Throw.
  - [x] Show an animated EXP bar in battle.
  - [x] Fix Focus Energy and make Ghost super effective against Psychic.

To set up the repository, see [**INSTALL.md**](INSTALL.md).

[ci]: https://github.com/wiigg/pokered/actions
[ci-badge]: https://github.com/wiigg/pokered/actions/workflows/main.yml/badge.svg
