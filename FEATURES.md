# Feature catalogue

> **Full gameplay spoilers:** this catalogue reveals hidden encounters, optional
> scenes, postgame events, and puzzle outcomes.

This is the canonical record of shipped player-facing changes in this fork.
Each future gameplay feature or fix should update this file in the same commit.

## Myths, mysteries, and hidden places

- **Mew under the truck:** the postgame [Vermilion Dock truck](scripts/VermilionDock.asm)
  can finally be moved with Strength, revealing a catchable level-30 Mew.
  If Mew is defeated, another League victory brings it back. Running or losing
  allows an immediate retry; a recorded capture keeps the encounter complete.
- **White Hand:** Lavender Town's old rumour leads to a hidden Haunter encounter
  in [Lavender Town](scripts/LavenderTown.asm).
- **Bill's Secret Garden:** Bill eventually opens a postgame garden carved into
  the mountains behind his house, with rare Eevee and Bulbasaur encounters. A
  unique level-25 Pikachu joins with Surf and Generation II shiny-compatible
  DVs. Its notebook hints at friendship evolution, day and night, alternate
  colours, and future PC links, while the pond offers one further glimpse of
  Kanto's future. Bill and an earlier Route 25 clue encourage a return visit.
  Mr. Psychic can restore this gift's Surf and Thunderbolt, including after
  evolution or when the Pikachu was received in an earlier build.
  See [the garden script](scripts/BillsSecretGarden.asm).
- **Clefairy Moonfall Ceremony:** a hidden ceremony takes place at Mt. Moon's
  original Moon Stone landing site. An earlier clue points towards the event;
  Pewter Museum's meteorite later remembers the ceremony and responds further
  to a lead Clefairy-family Pokémon. See [Mt. Moon 1F](scripts/MtMoon1F.asm)
  and [Museum 2F](scripts/Museum2F.asm).
- **Something beneath the S.S. Anne:** an enormous shadow passes beneath the
  ship when its bow is revisited after helping the Captain. See
  [S.S. Anne Bow](scripts/SSAnneBow.asm).
- **The ghost sailor:** Vermilion's empty dock later gains a solitary sailor
  who questions the S.S. Anne's fate, offers a difficult battle, and vanishes.
  See [Vermilion Dock](scripts/VermilionDock.asm).
- **The Underground Path phantom train:** a train can thunder beneath Saffron
  years before Kanto's electric railway exists. See
  [Underground Path](scripts/UndergroundPathWestEast.asm).
- **A safe MissingNo. reference:** one obscure Cinnabar shoreline tile produces
  a distorted sound and the message `NO. 000?`, while keeping the encounter
  system untouched. See [Cinnabar Island](scripts/CinnabarIsland.asm).
- **Game Freak's sequel experiment:** after becoming Champion, an office
  computer shows a restrained `POKéMON 2 / CLOCK TEST / MORNING... NIGHT...`
  development hint. See [Celadon Mansion 3F](scripts/CeladonMansion3F.asm).
- **Blue's missing Raticate:** a solitary Pokémon Tower memorial gives the old
  fan theory a quiet place in Kanto. See
  [Pokémon Tower 2F](scripts/PokemonTower2F.asm).
- **Ditto as failed Mew clones:** a torn Mansion diary connects Ditto to the Mew
  experiments. One obscure [Mansion statue](scripts/PokemonMansionB1F.asm)
  later distorts into a catchable Ditto.
- **Rock Tunnel's fossil imprint:** an Aerodactyl-shaped mark answers the Old
  Amber or a lead Aerodactyl with a distant cry and cave tremor. See
  [Rock Tunnel B1F](scripts/RockTunnelB1F.asm).
- **Snorlax's dream:** a lead Drowzee or Hypno can briefly glimpse a sleeping
  Snorlax's strange dream before the usual encounter. See
  [Route 12](scripts/Route12.asm).
- **Silph's unused Porygon monitor:** the original unused Porygon display and
  Pokédex presentation are restored on [Silph Co. 11F](scripts/SilphCo11F.asm).
- **The Celadon Chief mystery:** Celadon Hotel's invisible terminal reveals a
  Rocket shipment ledger and eventually opens a hidden battle with the Chief.
  See [Celadon Hotel](scripts/CeladonHotel.asm) and
  [the Chief's room](scripts/CeladonChiefHouse.asm).
- **Kanto's future railway:** the abandoned Power Plant returns to service after
  the League once its live cells and legendary bird are cleared. Restoration
  changes Route 10 dialogue, enables party recharging, and reveals plans for a
  future electric rail. See
  [the Power Plant](scripts/PowerPlant.asm).

## Character moments and a reactive Kanto

- **Progress-sensitive rumours:** Pewter's Clefairy enthusiast hints at an
  available Moonfall ceremony; Celadon's unlucky gambler spots the Rocket
  deserter; a Vermilion sailor points towards the truck, Mew's League-triggered
  return, or the unresolved ghost sailor. Each gives one current lead and
  resumes their original dialogue when their leads are resolved.
- **Oak's restless final Pokémon:** the unused ball in Oak's lab trembles after
  the opening rival battle and settles after Oak's postgame challenge. See
  [Oak's Lab](scripts/OaksLab.asm).
- **The complete Bulbasaur rustle thread:** an early Viridian Forest rustle and
  cry lead into the area's rare Bulbasaur encounter; the nearby Bug Catcher
  recognises what happened once Bulbasaur enters the Pokédex. See
  [Viridian Forest](scripts/ViridianForest.asm).
- **Pewter Jigglypuff duet:** the singing Jigglypuff in Pewter Pokémon Centre
  performs a duet when Jigglypuff or Wigglytuff leads the party. See
  [Pewter Pokémon Centre](scripts/PewterPokecenter.asm).
- **The Indigo Plateau guide recognises the Champion:** his familiar greeting
  changes after the Hall of Fame. See
  [Indigo Plateau Lobby](scripts/IndigoPlateauLobby.asm).
- **The Fan Club Chairman admires Rapidash:** a lead Rapidash earns a delighted
  reaction from its greatest fan. See
  [the Pokémon Fan Club](scripts/PokemonFanClub.asm).
- **Pewter Museum recognises revived fossils:** staff react to a lead Omanyte,
  Kabuto, or Aerodactyl. See [Museum 1F](scripts/Museum1F.asm).
- **Rhydon acknowledges Gym statues:** examining a Gym statue with Rhydon in
  front gives the series' original statue Pokémon a special reaction. See
  [the shared statue event](engine/events/hidden_events/gym_statues.asm).
- **The blue mouse rumour:** a Fuchsia child reports a round blue mouse beyond
  the Safari fence, preserving the old “Pikablu” speculation as hearsay. See
  [Fuchsia City](text/FuchsiaCity.asm).
- **Mr. Fuji recognises Mew and Mewtwo:** each lead Pokémon prompts a restrained
  reaction that deepens Fuji's connection to the Cinnabar experiments. See
  [Mr. Fuji's house](scripts/MrFujisHouse.asm).
- **Cubone's quiet goodbye:** a lead Cubone receives a final moment with
  Marowak's spirit in [Pokémon Tower 6F](scripts/PokemonTower6F.asm).
- **Lapras revisits its Silph rescuer:** the employee who entrusted Lapras to
  the player recognises it when it returns in front. See
  [Silph Co. 7F](scripts/SilphCo7F.asm).
- **Trade partners remember:** in-game trade NPCs recognise their former
  Pokémon when reunited, including evolved forms. See
  [the shared trade event](engine/events/in_game_trades.asm).
- **The deserter's second life:** after beating the Underground Path deserter
  and Giovanni at Silph, a hesitant fisherman and his familiar Raticate appear
  on the pier north of Route 12's Super Rod house. They now mend nets for an
  honest living; familiar speech connects this quiet scene to the earlier
  battle. Both remain hidden if an older save places the player on either
  new spot, allowing the player to step away. See [Route 12](scripts/Route12.asm).
- **Saffron's messenger Pidgey:** after beating Giovanni at Silph, speak to
  Pippi or the resting Pidgey in Saffron's letter-writing household to begin.
  The south gatehouse guard points towards the dropped letter on the left
  counter. Deliver it to Pippi, then carry her reply to Pidgey's worried owner
  in the house just south of Vermilion's Mart. The courier flies home during
  a fade, and the reunion earns one PP Up. A full bag leaves the reward
  claimable on a later visit without repeating the reunion. Letters use
  reserved event flags and take no bag space; the original save layout and
  item IDs are preserved. See
  [Saffron's household](scripts/SaffronPidgeyHouse.asm),
  [Route 6 gate](scripts/Route6Gate.asm), and
  [Vermilion's household](scripts/VermilionPidgeyHouse.asm).
- **Erik and Sara find each other:** the two Fuchsia NPCs waiting at different
  gates become a small message-delivery story. See
  [Fuchsia City](scripts/FuchsiaCity.asm).
- **Champion homecoming:** Mom acknowledges the Champion and their original
  starter when they return home. See [Red's House 1F](scripts/RedsHouse1F.asm).
- **A complete Pokédex epilogue:** catching all 151 earns new reactions from
  Oak and Game Freak plus a framed bedroom diploma. See
  [Oak's Lab](scripts/OaksLab.asm), [Celadon Mansion 3F](scripts/CeladonMansion3F.asm),
  and [Red's House 2F](scripts/RedsHouse2F.asm).
- **Oak answers the League invitation:** Oak's lab email gains a post-battle
  conclusion after the player defeats him. See
  [the lab email event](engine/events/hidden_events/oaks_lab_email.asm).

## Encounters, collection, and regional identity

- **All 151 Pokémon on one cartridge:** every species is obtainable through
  solo play. Kadabra, Machoke, Graveler, and Haunter evolve at level 40;
  starters and version exclusives appear as rare wild finds; both Mt. Moon
  fossils and both Fighting Dojo gifts can be claimed.
- **Restored CHIKUCHIKU trade:** the unused Butterfree-for-Beedrill exchange is
  active at [Viridian Forest's north gate](scripts/ViridianForestNorthGate.asm).
- **Remixed wild habitats:** encounter tables give each route, cave, forest,
  waterway, and dungeon a stronger identity with occasional rare finds.
- **Ancient Venusaur sighting:** after the rustle, Viridian Forest has an
  exceptionally rare level-100 Venusaur battle. It resists capture and rewards
  a successful fight with its full experience yield. See
  [Viridian Forest](scripts/ViridianForest.asm).
- **Legendary bird visitors:** Articuno, Zapdos, and Moltres make rare, fleeting
  level-50 appearances beyond their lairs. These visitors resist capture while
  their original catchable encounters remain in place. See
  [Route 20](scripts/Route20.asm),
  [Route 10](scripts/Route10.asm), and [Cinnabar Island](scripts/CinnabarIsland.asm).
- **Seafoam whirlpool Gyarados:** using the Super Rod on one precise deep-water
  tile hooks a catchable level-70 Gyarados with Hydro Pump, Blizzard, Thunder,
  and Hyper Beam. See
  [Seafoam Islands B4F](scripts/SeafoamIslandsB4F.asm).
- **Escaped Safari Rhyhorn:** a Rhyhorn charges through Fuchsia with the Warden
  in pursuit, leading to a standard catchable battle. See
  [Fuchsia City](scripts/FuchsiaCity.asm).
- **Safari Master challenge:** the Warden offers a postgame rare-Pokémon
  photo challenge for Chansey, Kangaskhan, Tauros, and Scyther or Pinsir. His
  display fills as it progresses, and completion awards free Safari entry. See
  [the Warden's house](scripts/WardensHouse.asm).

## Battles and optional challenges

- **Upgraded Gym Leaders:** all eight leaders use fuller teams, purposeful
  custom movesets, and a stronger difficulty curve.
- **Strengthened rivals:** rival battles gain fuller teams, improved movesets,
  and more pressure throughout the journey.
- **Rebuilt Elite Four and Champion:** the League keeps its recognisable themes,
  replaces Bruno's duplicate Onix with Primeape, uses custom movesets, and
  preserves every Champion starter branch.
- **Professor Oak superboss:** Oak becomes the strongest postgame trainer, with
  a team branch that responds to the player's original starter and supports
  repeat battles. See [Oak's Lab](scripts/OaksLab.asm).
- **Trial of Three:** the Fighting Dojo hosts a repeatable three-trainer gauntlet
  built around Swiftness, Endurance, and Mastery. The party's condition carries
  through all three battles. See
  [the Fighting Dojo](scripts/FightingDojo.asm).
- **Blue in Viridian Gym:** Blue trains with his future line-up in the empty Gym
  during the postgame. See [Viridian Gym](scripts/ViridianGym.asm).
- **The Viridian Old Man's Weedle grew up:** his catching-demo partner returns
  as a formidable level-55 Beedrill. See
  [Viridian City](scripts/ViridianCity.asm).
- **The shorts youngster returns:** Route 3's famous youngster appears near the
  League with level 72–80 evolutions of familiar early-route Pokémon. See
  [Route 23](scripts/Route23.asm).
- **Magikarp salesman's challenge:** the Mt. Moon salesman turns his “no
  refunds” pitch into a five-Pokémon Water-team battle once the player owns
  Gyarados, then pays a ¥500 dividend. See
  [Mt. Moon Pokémon Centre](scripts/MtMoonPokecenter.asm).
- **Copycat's mirror battle:** after receiving her Poké Doll, Copycat imitates
  the player's appearance and battles with a level-matched Ditto. See
  [Copycat's house](scripts/CopycatsHouse2F.asm).
- **Celadon rooftop trainer:** the girl who gives drink TMs reveals a much
  stronger Dewgong, Graveler, and Porygon team after receiving all three drinks.
  See
  [Celadon Mart Roof](scripts/CeladonMartRoof.asm).
- **Rocket deserter:** between the Hideout and Silph, a frightened Grunt battles
  the player, warns that Giovanni has gone to Saffron, abandons his uniform, and
  leaves in a flash. His discarded uniform remains as an examinable bundle,
  including on later visits. See [Underground Path](scripts/UndergroundPathWestEast.asm).

## Red+ conveniences and balance

- **Hold B to run:** running accelerates ordinary walking, and the Viridian Old
  Man teaches the control naturally during the opening journey.
- **Reusable TMs:** TMs remain available after teaching a move.
- **Contextual field HMs:** pressing A on water, cuttable trees, or Strength
  boulders offers the matching HM action directly.
- **Trainer attention:** trainers turn to face the player when they spot them.
- **Move remembering and forgetting:** Mr. Psychic restores natural level-up
  moves and the garden gift's special moves, and removes unwanted moves,
  including HMs. See
  [Mr. Psychic's house](scripts/MrPsychicsHouse.asm).
- **Automatic PC-box rollover:** a full active box advances to the next box with
  space and saves that selection.
- **Animated EXP bar:** battles show experience progress after a gain.
- **Caught indicator:** wild battles mark species already registered as caught.
- **Preserved League-approach music:** cycling keeps the Route 23, Victory Road,
  and Indigo Plateau themes playing.
- **Fast text by default:** new games begin with fast text while existing saves
  retain their chosen option.
- **Improved overlooked moves:** Cut, Wing Attack, Vine Whip, Poison Sting, Pin
  Missile, Submission, Rock Throw, Lick, Smog, Constrict, Leech Life, and Bubble
  receive carefully selected power or accuracy improvements.
- **Sensible learnset corrections:** Kadabra and Alakazam gain Kinesis, Charizard
  gains Fly compatibility, Scyther gains Wing Attack, Tangela gains Vine Whip,
  and Butterfree learns Confusion upon evolving.

## Gen I fixes and compatibility safeguards

- **Focus Energy:** the move now raises the critical-hit rate as its description
  implies.
- **Ghost versus Psychic:** Ghost attacks are super effective against Psychic.
- **Reliable healing:** Recover, Softboiled, and Rest correctly compare both HP
  bytes, including when exactly 255 or 511 HP is missing.
- **Safe Substitute cost:** Substitute requires enough HP to leave its user
  with at least 1 HP after paying the cost.
- **Transform targeting:** Transform checks its target's Fly/Dig invulnerability
  correctly on both the player's and the opponent's turns.
- **Zero-Defence damage:** damage calculation handles a zero Defence value and
  avoids the original battle freeze.
- **Mirrored trapping moves:** link battles synchronise trapping effects copied
  through Mirror Move.
- **Bide damage:** Bide stores actual HP damage after substitutes and other
  reductions.
- **Dual-type effectiveness messages:** battle text reflects the combined type
  result accurately.
- **Trainer type scoring:** AI combines both defensive types, including
  cancelling weaknesses and resistances, and applies type-based move preferences
  to damaging moves. Status moves keep their own tactical checks.
- **Skipped-level moves:** a Pokémon gaining several levels from one battle gets
  the chance to learn every move crossed along the way.
- **Evolution stones:** stone evolutions require the matching stone action.
- **Wild DVs:** wild encounters use the complete intended determinant-value
  range.
- **Cooltrainer♀ AI:** the documented probability mistake in its special AI is
  corrected.
- **Save-layout guard:** `make check-save-compat` verifies the protected SRAM and
  WRAM layout plus established IDs, covering 1,547 save-sensitive symbols.
- **Gameplay regression checks:** `make check-gameplay` tests compiled battle
  routines, full-storage gifts, one-time rewards, scripted encounter outcomes,
  multi-map story progress, map re-entry and selected dialogue widths across
  all three builds.
