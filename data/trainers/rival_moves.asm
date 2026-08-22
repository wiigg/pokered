; Move set suffixes identify the rival's starter, not the player's.
; RIVAL1 trainers 4-9: early Route 22, then Cerulean City.
Rival1MoveSetPointers:
	table_width 2
	dw Rival1Route22SquirtleMoves
	dw Rival1Route22BulbasaurMoves
	dw Rival1Route22CharmanderMoves
	dw Rival1CeruleanSquirtleMoves
	dw Rival1CeruleanBulbasaurMoves
	dw Rival1CeruleanCharmanderMoves
	assert_table_length 6

; RIVAL2 trainers 1-12, in encounter and starter order.
Rival2MoveSetPointers:
	table_width 2
	dw Rival2SSAnneSquirtleMoves
	dw Rival2SSAnneBulbasaurMoves
	dw Rival2SSAnneCharmanderMoves
	dw Rival2PokemonTowerSquirtleMoves
	dw Rival2PokemonTowerBulbasaurMoves
	dw Rival2PokemonTowerCharmanderMoves
	dw Rival2SilphCoSquirtleMoves
	dw Rival2SilphCoBulbasaurMoves
	dw Rival2SilphCoCharmanderMoves
	dw Rival2Route22SquirtleMoves
	dw Rival2Route22BulbasaurMoves
	dw Rival2Route22CharmanderMoves
	assert_table_length 12

Rival1Route22SquirtleMoves:
	db GUST,          SAND_ATTACK, NO_MOVE,      NO_MOVE ; Pidgey
	db TACKLE,        TAIL_WHIP,   BUBBLE,       NO_MOVE ; Squirtle
.end
	assert .end - Rival1Route22SquirtleMoves == 2 * NUM_MOVES

Rival1Route22BulbasaurMoves:
	db GUST,          SAND_ATTACK, NO_MOVE,      NO_MOVE ; Pidgey
	db TACKLE,        GROWL,       LEECH_SEED,   VINE_WHIP ; Bulbasaur
.end
	assert .end - Rival1Route22BulbasaurMoves == 2 * NUM_MOVES

Rival1Route22CharmanderMoves:
	db GUST,          SAND_ATTACK, NO_MOVE,      NO_MOVE ; Pidgey
	db SCRATCH,       GROWL,       EMBER,        NO_MOVE ; Charmander
.end
	assert .end - Rival1Route22CharmanderMoves == 2 * NUM_MOVES

Rival1CeruleanSquirtleMoves:
	db GUST,          SAND_ATTACK, QUICK_ATTACK, NO_MOVE      ; Pidgeotto
	db SEISMIC_TOSS,  THUNDER_WAVE, NO_MOVE,      NO_MOVE      ; Abra
	db TACKLE,        TAIL_WHIP,   QUICK_ATTACK, HYPER_FANG   ; Rattata
	db TACKLE,        TAIL_WHIP,   BUBBLE,       WATER_GUN    ; Wartortle
.end
	assert .end - Rival1CeruleanSquirtleMoves == 4 * NUM_MOVES

Rival1CeruleanBulbasaurMoves:
	db GUST,          SAND_ATTACK, QUICK_ATTACK, NO_MOVE      ; Pidgeotto
	db SEISMIC_TOSS,  THUNDER_WAVE, NO_MOVE,      NO_MOVE      ; Abra
	db TACKLE,        TAIL_WHIP,   QUICK_ATTACK, HYPER_FANG   ; Rattata
	db TACKLE,        GROWL,       LEECH_SEED,   VINE_WHIP    ; Ivysaur
.end
	assert .end - Rival1CeruleanBulbasaurMoves == 4 * NUM_MOVES

Rival1CeruleanCharmanderMoves:
	db GUST,          SAND_ATTACK, QUICK_ATTACK, NO_MOVE      ; Pidgeotto
	db SEISMIC_TOSS,  THUNDER_WAVE, NO_MOVE,      NO_MOVE      ; Abra
	db TACKLE,        TAIL_WHIP,   QUICK_ATTACK, HYPER_FANG   ; Rattata
	db SCRATCH,       GROWL,       EMBER,        LEER         ; Charmeleon
.end
	assert .end - Rival1CeruleanCharmanderMoves == 4 * NUM_MOVES

Rival2SSAnneSquirtleMoves:
	db GUST,          SAND_ATTACK, QUICK_ATTACK, NO_MOVE      ; Pidgeotto
	db TAIL_WHIP,     QUICK_ATTACK, HYPER_FANG,   BODY_SLAM    ; Raticate
	db CONFUSION,     DISABLE,      SEISMIC_TOSS, THUNDER_WAVE ; Kadabra
	db BUBBLE,        WATER_GUN,    BITE,         TAIL_WHIP    ; Wartortle
.end
	assert .end - Rival2SSAnneSquirtleMoves == 4 * NUM_MOVES

Rival2SSAnneBulbasaurMoves:
	db GUST,          SAND_ATTACK, QUICK_ATTACK, NO_MOVE      ; Pidgeotto
	db TAIL_WHIP,     QUICK_ATTACK, HYPER_FANG,   BODY_SLAM    ; Raticate
	db CONFUSION,     DISABLE,      SEISMIC_TOSS, THUNDER_WAVE ; Kadabra
	db VINE_WHIP,     LEECH_SEED,   POISONPOWDER, TACKLE       ; Ivysaur
.end
	assert .end - Rival2SSAnneBulbasaurMoves == 4 * NUM_MOVES

Rival2SSAnneCharmanderMoves:
	db GUST,          SAND_ATTACK, QUICK_ATTACK, NO_MOVE      ; Pidgeotto
	db TAIL_WHIP,     QUICK_ATTACK, HYPER_FANG,   BODY_SLAM    ; Raticate
	db CONFUSION,     DISABLE,      SEISMIC_TOSS, THUNDER_WAVE ; Kadabra
	db EMBER,         LEER,         RAGE,         MEGA_PUNCH   ; Charmeleon
.end
	assert .end - Rival2SSAnneCharmanderMoves == 4 * NUM_MOVES

Rival2PokemonTowerSquirtleMoves:
	db GUST,          WING_ATTACK, QUICK_ATTACK, SAND_ATTACK  ; Pidgeotto
	db BITE,          EMBER,       LEER,         TAKE_DOWN    ; Growlithe
	db BARRAGE,       HYPNOSIS,    REFLECT,      LEECH_SEED   ; Exeggcute
	db CONFUSION,     PSYBEAM,     DISABLE,      THUNDER_WAVE ; Kadabra
	db BUBBLEBEAM,    BITE,        WATER_GUN,    WITHDRAW     ; Wartortle
.end
	assert .end - Rival2PokemonTowerSquirtleMoves == 5 * NUM_MOVES

Rival2PokemonTowerBulbasaurMoves:
	db GUST,          WING_ATTACK, QUICK_ATTACK, SAND_ATTACK  ; Pidgeotto
	db BITE,          DRAGON_RAGE, BUBBLEBEAM,   LEER         ; Gyarados
	db BITE,          EMBER,       LEER,         TAKE_DOWN    ; Growlithe
	db CONFUSION,     PSYBEAM,     DISABLE,      THUNDER_WAVE ; Kadabra
	db RAZOR_LEAF,    VINE_WHIP,   LEECH_SEED,   POISONPOWDER ; Ivysaur
.end
	assert .end - Rival2PokemonTowerBulbasaurMoves == 5 * NUM_MOVES

Rival2PokemonTowerCharmanderMoves:
	db GUST,          WING_ATTACK, QUICK_ATTACK, SAND_ATTACK  ; Pidgeotto
	db BARRAGE,       HYPNOSIS,    REFLECT,      LEECH_SEED   ; Exeggcute
	db BITE,          DRAGON_RAGE, BUBBLEBEAM,   LEER         ; Gyarados
	db CONFUSION,     PSYBEAM,     DISABLE,      THUNDER_WAVE ; Kadabra
	db EMBER,         DIG,         RAGE,         MEGA_PUNCH   ; Charmeleon
.end
	assert .end - Rival2PokemonTowerCharmanderMoves == 5 * NUM_MOVES

Rival2SilphCoSquirtleMoves:
	db WING_ATTACK,   FLY,          QUICK_ATTACK, SAND_ATTACK ; Pidgeot
	db HORN_ATTACK,   STOMP,        DIG,          ROCK_SLIDE  ; Rhyhorn
	db BITE,          EMBER,        TAKE_DOWN,    DIG         ; Growlithe
	db PSYCHIC_M,     LEECH_SEED,   STUN_SPORE,   EGG_BOMB    ; Exeggcute
	db PSYCHIC_M,     RECOVER,      REFLECT,      THUNDER_WAVE ; Alakazam
	db SURF,          BITE,         ICE_BEAM,     WITHDRAW    ; Blastoise
.end
	assert .end - Rival2SilphCoSquirtleMoves == 6 * NUM_MOVES

Rival2SilphCoBulbasaurMoves:
	db WING_ATTACK,   FLY,          QUICK_ATTACK, SAND_ATTACK ; Pidgeot
	db HORN_ATTACK,   STOMP,        DIG,          ROCK_SLIDE  ; Rhyhorn
	db SURF,          BITE,         ICE_BEAM,     DRAGON_RAGE ; Gyarados
	db BITE,          EMBER,        TAKE_DOWN,    DIG         ; Growlithe
	db PSYCHIC_M,     RECOVER,      REFLECT,      THUNDER_WAVE ; Alakazam
	db RAZOR_LEAF,    MEGA_DRAIN,   LEECH_SEED,   POISONPOWDER ; Venusaur
.end
	assert .end - Rival2SilphCoBulbasaurMoves == 6 * NUM_MOVES

Rival2SilphCoCharmanderMoves:
	db WING_ATTACK,   FLY,          QUICK_ATTACK, SAND_ATTACK ; Pidgeot
	db HORN_ATTACK,   STOMP,        DIG,          ROCK_SLIDE  ; Rhyhorn
	db PSYCHIC_M,     LEECH_SEED,   STUN_SPORE,   EGG_BOMB    ; Exeggcute
	db SURF,          BITE,         ICE_BEAM,     DRAGON_RAGE ; Gyarados
	db PSYCHIC_M,     RECOVER,      REFLECT,      THUNDER_WAVE ; Alakazam
	db FLAMETHROWER,  SLASH,        DIG,          REFLECT     ; Charizard
.end
	assert .end - Rival2SilphCoCharmanderMoves == 6 * NUM_MOVES

Rival2Route22SquirtleMoves:
	db WING_ATTACK,   FLY,          QUICK_ATTACK, AGILITY     ; Pidgeot
	db EARTHQUAKE,    ROCK_SLIDE,   STOMP,        BODY_SLAM   ; Rhydon
	db FIRE_BLAST,    BODY_SLAM,    DIG,          REFLECT     ; Arcanine
	db PSYCHIC_M,     MEGA_DRAIN,   SLEEP_POWDER, EGG_BOMB    ; Exeggutor
	db PSYCHIC_M,     RECOVER,      REFLECT,      THUNDER_WAVE ; Alakazam
	db SURF,          BLIZZARD,     EARTHQUAKE,   BODY_SLAM   ; Blastoise
.end
	assert .end - Rival2Route22SquirtleMoves == 6 * NUM_MOVES

Rival2Route22BulbasaurMoves:
	db WING_ATTACK,   FLY,          QUICK_ATTACK, AGILITY     ; Pidgeot
	db EARTHQUAKE,    ROCK_SLIDE,   STOMP,        BODY_SLAM   ; Rhydon
	db SURF,          ICE_BEAM,     THUNDERBOLT,  HYPER_BEAM  ; Gyarados
	db FIRE_BLAST,    BODY_SLAM,    DIG,          REFLECT     ; Arcanine
	db PSYCHIC_M,     RECOVER,      REFLECT,      THUNDER_WAVE ; Alakazam
	db RAZOR_LEAF,    SLEEP_POWDER, MEGA_DRAIN,   BODY_SLAM   ; Venusaur
.end
	assert .end - Rival2Route22BulbasaurMoves == 6 * NUM_MOVES

Rival2Route22CharmanderMoves:
	db WING_ATTACK,   FLY,          QUICK_ATTACK, AGILITY     ; Pidgeot
	db EARTHQUAKE,    ROCK_SLIDE,   STOMP,        BODY_SLAM   ; Rhydon
	db PSYCHIC_M,     MEGA_DRAIN,   SLEEP_POWDER, EGG_BOMB    ; Exeggutor
	db SURF,          ICE_BEAM,     THUNDERBOLT,  HYPER_BEAM  ; Gyarados
	db PSYCHIC_M,     RECOVER,      REFLECT,      THUNDER_WAVE ; Alakazam
	db FIRE_BLAST,    SLASH,        EARTHQUAKE,   SWORDS_DANCE ; Charizard
.end
	assert .end - Rival2Route22CharmanderMoves == 6 * NUM_MOVES
