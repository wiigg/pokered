LoreleiMoveSets:
	db SURF,          ICE_BEAM,    BODY_SLAM,    TOXIC        ; Dewgong
	db CLAMP,         BLIZZARD,    SURF,          REFLECT      ; Cloyster
	db SURF,          PSYCHIC_M,   AMNESIA,       ICE_BEAM     ; Slowbro
	db BLIZZARD,      PSYCHIC_M,   LOVELY_KISS,   SEISMIC_TOSS ; Jynx
	db SURF,          BLIZZARD,    THUNDERBOLT,   CONFUSE_RAY  ; Lapras
.end
	assert .end - LoreleiMoveSets == ELITE_FOUR_PARTY_LENGTH * NUM_MOVES

BrunoMoveSets:
	db EARTHQUAKE,    ROCK_SLIDE,  BODY_SLAM,    SCREECH      ; Onix
	db SUBMISSION,    MEGA_PUNCH,  BODY_SLAM,    SEISMIC_TOSS ; Hitmonchan
	db HI_JUMP_KICK,  MEGA_KICK,   MEDITATE,      BODY_SLAM    ; Hitmonlee
	db SUBMISSION,    ROCK_SLIDE,  BODY_SLAM,    THRASH       ; Primeape
	db SUBMISSION,    EARTHQUAKE,  ROCK_SLIDE,   BODY_SLAM    ; Machamp
.end
	assert .end - BrunoMoveSets == ELITE_FOUR_PARTY_LENGTH * NUM_MOVES

AgathaMoveSets:
	db PSYCHIC_M,     THUNDERBOLT, CONFUSE_RAY,   NIGHT_SHADE  ; Gengar
	db WING_ATTACK,   BITE,        CONFUSE_RAY,   TOXIC        ; Golbat
	db PSYCHIC_M,     MEGA_DRAIN,  HYPNOSIS,      NIGHT_SHADE  ; Haunter
	db BODY_SLAM,     EARTHQUAKE,  ROCK_SLIDE,   GLARE        ; Arbok
	db PSYCHIC_M,     THUNDERBOLT, MEGA_DRAIN,    TOXIC        ; Gengar
.end
	assert .end - AgathaMoveSets == ELITE_FOUR_PARTY_LENGTH * NUM_MOVES

LanceMoveSets:
	db HYDRO_PUMP,    THUNDERBOLT, BLIZZARD,      BODY_SLAM    ; Gyarados
	db THUNDER_WAVE,  THUNDERBOLT, SURF,          HYPER_BEAM   ; Dragonair
	db BLIZZARD,      FIRE_BLAST,  BODY_SLAM,     AGILITY      ; Dragonair
	db WING_ATTACK,   FIRE_BLAST,  DOUBLE_EDGE,   HYPER_BEAM   ; Aerodactyl
	db BLIZZARD,      THUNDERBOLT, SURF,          HYPER_BEAM   ; Dragonite
.end
	assert .end - LanceMoveSets == ELITE_FOUR_PARTY_LENGTH * NUM_MOVES

; Move set suffixes identify the rival's starter, not the player's.
ChampionMoveSetPointers:
	table_width 2
	dw ChampionSquirtleMoveSets
	dw ChampionBulbasaurMoveSets
	dw ChampionCharmanderMoveSets
	assert_table_length 3

ChampionSquirtleMoveSets:
	db SKY_ATTACK,    WING_ATTACK, AGILITY,       HYPER_BEAM   ; Pidgeot
	db PSYCHIC_M,     RECOVER,     REFLECT,       THUNDER_WAVE ; Alakazam
	db EARTHQUAKE,    ROCK_SLIDE,  BODY_SLAM,     SUBMISSION   ; Rhydon
	db FIRE_BLAST,    BODY_SLAM,   DIG,           REFLECT      ; Arcanine
	db PSYCHIC_M,     MEGA_DRAIN,  SLEEP_POWDER,  EGG_BOMB     ; Exeggutor
	db HYDRO_PUMP,    BLIZZARD,    EARTHQUAKE,    BODY_SLAM    ; Blastoise
.end
	assert .end - ChampionSquirtleMoveSets == PARTY_LENGTH * NUM_MOVES

ChampionBulbasaurMoveSets:
	db SKY_ATTACK,    WING_ATTACK, AGILITY,       HYPER_BEAM   ; Pidgeot
	db PSYCHIC_M,     RECOVER,     REFLECT,       THUNDER_WAVE ; Alakazam
	db EARTHQUAKE,    ROCK_SLIDE,  BODY_SLAM,     SUBMISSION   ; Rhydon
	db HYDRO_PUMP,    BLIZZARD,    THUNDERBOLT,   HYPER_BEAM   ; Gyarados
	db FIRE_BLAST,    BODY_SLAM,   DIG,           REFLECT      ; Arcanine
	db RAZOR_LEAF,    SLEEP_POWDER, MEGA_DRAIN,   BODY_SLAM    ; Venusaur
.end
	assert .end - ChampionBulbasaurMoveSets == PARTY_LENGTH * NUM_MOVES

ChampionCharmanderMoveSets:
	db SKY_ATTACK,    WING_ATTACK, AGILITY,       HYPER_BEAM   ; Pidgeot
	db PSYCHIC_M,     RECOVER,     REFLECT,       THUNDER_WAVE ; Alakazam
	db EARTHQUAKE,    ROCK_SLIDE,  BODY_SLAM,     SUBMISSION   ; Rhydon
	db PSYCHIC_M,     MEGA_DRAIN,  SLEEP_POWDER,  EGG_BOMB     ; Exeggutor
	db HYDRO_PUMP,    BLIZZARD,    THUNDERBOLT,   HYPER_BEAM   ; Gyarados
	db FIRE_BLAST,    SLASH,       EARTHQUAKE,    REFLECT      ; Charizard
.end
	assert .end - ChampionCharmanderMoveSets == PARTY_LENGTH * NUM_MOVES
