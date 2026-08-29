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
an original location that an unmodified game can load safely. Every full build
checks the original byte layout and core stored IDs automatically; run
`make check-save-compat` to invoke it directly.

## Roadmap

- [x] Make the “Mew under the truck” myth real using the [Vermilion Dock script](scripts/VermilionDock.asm#L1).
- [x] Seed the early adventure with [Oak's restless last Pokémon](scripts/OaksLab.asm), an unusual [Viridian Forest rustle](scripts/ViridianForest.asm), and an almost-impossible ancient Venusaur sighting.
- [x] Let Pewter Pokémon Centre's singing Jigglypuff perform a duet with a matching lead Pokémon.
- [x] Let Articuno, Zapdos, and Moltres make rare visits beyond their lairs without replacing their original catchable encounters.
- [x] Hide a vicious level-70 [Gyarados beneath Seafoam's deepest whirlpool](scripts/SeafoamIslandsB4F.asm), hooked only by one precise Super Rod cast.
- [x] Let the [Viridian Old Man's Weedle grow up](scripts/ViridianCity.asm) into a formidable Beedrill partner.
- [x] Bring back Route 3's [shorts youngster](scripts/Route23.asm) near the League with a wildly overtrained early-route team.
- [x] Let [Mr. Fuji recognise](scripts/MrFujisHouse.asm) a lead Mewtwo or Mew without explaining his past.
- [x] Make Lavender Town's [“white hand” rumour](scripts/LavenderTown.asm) real with a hidden Haunter encounter.
- [x] Let a lead [Cubone quietly say goodbye](scripts/PokemonTower6F.asm) when its mother's spirit departs.
- [x] Set apart a solitary [memorial to Blue's missing Raticate](scripts/PokemonTower2F.asm) in Pokémon Tower.
- [x] Hint through a torn [Pokémon Mansion diary](text/PokemonMansionB1F.asm) that Ditto may be failed Mew clones.
- [x] Let one [Pokémon Mansion statue](scripts/PokemonMansionB1F.asm) reveal itself as a catchable Ditto from those failed experiments.
- [x] Give [Copycat](scripts/CopycatsHouse2F.asm) a mirror battle with the player's appearance and a level-matched Ditto.
- [x] Turn Celadon Hotel's [invisible PC](scripts/CeladonHotel.asm) into a Rocket shipment mystery ending in a hidden [Chief battle](scripts/CeladonChiefHouse.asm).
- [x] Restore Silph Co.'s unused [Porygon monitor](scripts/SilphCo11F.asm) and its original Pokédex display.
- [x] Let the [Silph employee](scripts/SilphCo7F.asm) recognise the Lapras he entrusted to you when it returns at the head of the party.
- [x] Hide an [Aerodactyl fossil imprint](scripts/RockTunnelB1F.asm) in Rock Tunnel that answers the Old Amber or a lead Aerodactyl.
- [x] Let a lead Drowzee or Hypno glimpse a sleeping [Snorlax's strange dream](scripts/Route12.asm) before waking it normally.
- [x] Make [Bill's Secret Garden](scripts/BillsSecretGarden.asm) real as a postgame Eevee-family secret foreshadowed by Bill, with a unique Surfing Pikachu and hints of discoveries still to come.
- [x] Add a [Clefairy Moonfall Ceremony](scripts/MtMoon1F.asm) at Mt. Moon's original Moon Stone landing site, echoed by Pewter Museum's meteorite.
- [x] Give Mt. Moon's [Magikarp salesman](scripts/MtMoonPokecenter.asm) a “no refunds” challenge after discovering Gyarados's potential.
- [x] Let something enormous pass beneath the [S.S. Anne](scripts/SSAnneBow.asm) when the player returns to its bow after helping the Captain.
- [x] Let a solitary [ghost sailor](scripts/VermilionDock.asm) wait on the empty dock with a troubling claim about the S.S. Anne's final voyage.
- [x] Help [Erik and Sara](scripts/FuchsiaCity.asm) find each other at Fuchsia City's different gates.
- [x] Let an escaped [Safari Rhyhorn charge through Fuchsia](scripts/FuchsiaCity.asm), with the Warden in pursuit and a normal chance to catch it.
- [x] Complete the Warden's postgame [Safari Master challenge](scripts/WardensHouse.asm), fill his rare-Pokémon photo display, and earn free Safari entry.
- [x] Add Professor Oak as a postgame superboss, then let him finally answer the League's old invitation.
- [x] Give a completed 151-species Pokédex a proper epilogue and a framed bedroom diploma.
- [x] Give the Champion and their original starter a proper [homecoming with Mom](scripts/RedsHouse1F.asm).
- [x] Restore the abandoned [Power Plant](scripts/PowerPlant.asm) after the League and uncover a blueprint for Kanto's future electric rail.
- [x] Let a [phantom train](scripts/UndergroundPathWestEast.asm) thunder beneath Saffron years before that electric rail is built.
- [x] Meet a frightened [Rocket deserter](scripts/UndergroundPathWestEast.asm) between Giovanni's Celadon retreat and the Silph takeover.
- [x] Add a repeatable [Trial of Three](scripts/FightingDojo.asm) gauntlet with no rest between battles.
- [x] Let Blue train with his future line-up in the empty [Viridian Gym](scripts/ViridianGym.asm).
- [x] Make all 151 Pokémon obtainable on one cartridge, with former trade evolutions occurring at level 40.
- [x] Restore the unused CHIKUCHIKU Butterfree-for-Beedrill trade at Viridian Forest's north gate.
- [x] Let [in-game trade partners](engine/events/in_game_trades.asm) recognise their old Pokémon when reunited, including evolved forms.
- [x] Remix wild encounters so each area has a stronger identity and occasional exciting rare finds.
- [x] Upgrade major trainers with fuller, smarter teams:
  - [x] Upgrade all eight Gym Leaders.
  - [x] Strengthen rival battles.
  - [x] Rebuild the Elite Four and Champion.
- [x] Add a small “Red+” package:
  - [x] Make TMs reusable.
  - [x] Hold B to run while walking.
  - [x] Press A at water, cuttable trees, and Strength boulders to use HMs directly.
  - [x] Turn to face trainers who spot you before they speak.
  - [x] Let [Mr. Psychic](scripts/MrPsychicsHouse.asm) restore natural moves or erase unwanted moves, including HMs.
  - [x] Automatically select and save the next available PC box when the current one fills.
  - [x] Improve overlooked moves such as Cut, Wing Attack, Vine Whip, Leech Life, and Rock Throw.
  - [x] Show an animated EXP bar in battle.
  - [x] Mark wild Pokémon species that have already been caught.
  - [x] Preserve Route 23, Victory Road, and Indigo Plateau music while cycling.
  - [x] Apply selected natural learnset corrections, including Kinesis for Kadabra and Alakazam.
  - [x] Default new games to fast text while respecting existing save settings.
  - [x] Fix Focus Energy and make Ghost super effective against Psychic.

To set up the repository, see [**INSTALL.md**](INSTALL.md).

[ci]: https://github.com/wiigg/pokered/actions
[ci-badge]: https://github.com/wiigg/pokered/actions/workflows/main.yml/badge.svg
