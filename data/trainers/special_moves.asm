; Indexed by wGymLeaderNo in badge order, not by trainer class.
GymLeaderMoveSetPointers:
	table_width 2
	dw BrockMoveSets
	dw MistyMoveSets
	dw LtSurgeMoveSets
	dw ErikaMoveSets
	dw KogaMoveSets
	dw SabrinaMoveSets
	dw BlaineMoveSets
	dw GiovanniMoveSets
	assert_table_length 8

BrockMoveSets:
	db TACKLE,       DEFENSE_CURL, ROCK_THROW,    RAGE         ; Geodude
	db SCRATCH,      SAND_ATTACK,  POISON_STING,  SWIFT        ; Sandshrew
	db TACKLE,       SCREECH,      BIND,          BIDE         ; Onix
BrockMoveSetsEnd:
	assert BrockMoveSetsEnd - BrockMoveSets == 3 * NUM_MOVES

MistyMoveSets:
	db SCRATCH,      WATER_GUN,    DISABLE,       CONFUSION    ; Psyduck
	db TACKLE,       WATER_GUN,    HARDEN,        SWIFT        ; Staryu
	db WATER_GUN,    HARDEN,       SWIFT,         BUBBLEBEAM   ; Starmie
MistyMoveSetsEnd:
	assert MistyMoveSetsEnd - MistyMoveSets == 3 * NUM_MOVES

LtSurgeMoveSets:
	db TACKLE,       SCREECH,      SONICBOOM,     SELFDESTRUCT ; Voltorb
	db TACKLE,       SONICBOOM,    THUNDERSHOCK,  THUNDER_WAVE ; Magnemite
	db THUNDERSHOCK, THUNDER_WAVE, QUICK_ATTACK, DOUBLE_TEAM  ; Pikachu
	db THUNDER_WAVE, QUICK_ATTACK, MEGA_PUNCH,    THUNDERBOLT  ; Raichu
LtSurgeMoveSetsEnd:
	assert LtSurgeMoveSetsEnd - LtSurgeMoveSets == 4 * NUM_MOVES

ErikaMoveSets:
	db CONSTRICT,    ABSORB,       STUN_SPORE,    GROWTH       ; Tangela
	db BARRAGE,      HYPNOSIS,     REFLECT,       LEECH_SEED   ; Exeggcute
	db RAZOR_LEAF,   WRAP,         SLEEP_POWDER,  ACID         ; Victreebel
	db ACID,         STUN_SPORE,   PETAL_DANCE,   MEGA_DRAIN   ; Vileplume
ErikaMoveSetsEnd:
	assert ErikaMoveSetsEnd - ErikaMoveSets == 4 * NUM_MOVES

KogaMoveSets:
	db SLUDGE,       SMOKESCREEN,  THUNDERBOLT,   DOUBLE_TEAM  ; Koffing
	db WING_ATTACK,  BITE,         CONFUSE_RAY,   MEGA_DRAIN   ; Golbat
	db WRAP,         GLARE,        BITE,          BODY_SLAM    ; Arbok
	db SLUDGE,       MINIMIZE,     BODY_SLAM,     MEGA_DRAIN   ; Muk
	db SLUDGE,       SMOKESCREEN,  SELFDESTRUCT,  TOXIC        ; Weezing
KogaMoveSetsEnd:
	assert KogaMoveSetsEnd - KogaMoveSets == 5 * NUM_MOVES

SabrinaMoveSets:
	db DISABLE,      PSYCHIC_M,    RECOVER,       REFLECT      ; Kadabra
	db PSYCHIC_M,    BARRIER,      LIGHT_SCREEN,  THUNDER_WAVE ; Mr. Mime
	db PSYBEAM,      SLEEP_POWDER, STUN_SPORE,    MEGA_DRAIN   ; Venomoth
	db SURF,         PSYCHIC_M,    AMNESIA,       ICE_BEAM     ; Slowbro
	db PSYCHIC_M,    RECOVER,      REFLECT,       PSYWAVE      ; Alakazam
SabrinaMoveSetsEnd:
	assert SabrinaMoveSetsEnd - SabrinaMoveSets == 5 * NUM_MOVES

BlaineMoveSets:
	db FIRE_SPIN,    STOMP,        BODY_SLAM,     DOUBLE_TEAM  ; Ponyta
	db FLAMETHROWER, TAKE_DOWN,    AGILITY,       DIG          ; Growlithe
	db FIRE_PUNCH,   CONFUSE_RAY,  PSYCHIC_M,     BODY_SLAM    ; Magmar
	db FIRE_SPIN,    STOMP,        TAKE_DOWN,     REFLECT      ; Rapidash
	db BODY_SLAM,    DIG,          REFLECT,       FIRE_BLAST   ; Arcanine
BlaineMoveSetsEnd:
	assert BlaineMoveSetsEnd - BlaineMoveSets == 5 * NUM_MOVES

GiovanniMoveSets:
	db EARTHQUAKE,   ROCK_SLIDE,   STOMP,         BODY_SLAM    ; Rhyhorn
	db EARTHQUAKE,   SLASH,        SAND_ATTACK,   ROCK_SLIDE   ; Dugtrio
	db SLASH,        BUBBLEBEAM,   THUNDERBOLT,   SCREECH      ; Persian
	db EARTHQUAKE,   BODY_SLAM,    ICE_BEAM,      THUNDERBOLT  ; Nidoqueen
	db EARTHQUAKE,   ROCK_SLIDE,   THUNDERBOLT,   THRASH       ; Nidoking
	db EARTHQUAKE,   ROCK_SLIDE,   BODY_SLAM,     FISSURE      ; Rhydon
GiovanniMoveSetsEnd:
	assert GiovanniMoveSetsEnd - GiovanniMoveSets == 6 * NUM_MOVES

ViridianOldManMoveSet:
	db SWORDS_DANCE, TWINEEDLE, SWIFT, HYPER_BEAM ; Beedrill
ViridianOldManMoveSetEnd:
	assert ViridianOldManMoveSetEnd - ViridianOldManMoveSet == VIRIDIAN_OLD_MAN_PARTY_LENGTH * NUM_MOVES

ProfOakMoveSets:
; Blastoise team
	db TRI_ATTACK, SHARPEN, ICE_BEAM, THUNDERBOLT
	db BODY_SLAM, EARTHQUAKE, BLIZZARD, HYPER_BEAM
	db PSYCHIC_M, MEGA_DRAIN, SLEEP_POWDER, EGG_BOMB
	db FLAMETHROWER, BODY_SLAM, DIG, REFLECT
	db SURF, BLIZZARD, EARTHQUAKE, BODY_SLAM
	db SURF, BLIZZARD, THUNDERBOLT, HYPER_BEAM
; Venusaur team
	db TRI_ATTACK, SHARPEN, ICE_BEAM, THUNDERBOLT
	db BODY_SLAM, EARTHQUAKE, BLIZZARD, HYPER_BEAM
	db PSYCHIC_M, MEGA_DRAIN, SLEEP_POWDER, EGG_BOMB
	db FLAMETHROWER, BODY_SLAM, DIG, REFLECT
	db RAZOR_LEAF, SLEEP_POWDER, MEGA_DRAIN, BODY_SLAM
	db SURF, BLIZZARD, THUNDERBOLT, HYPER_BEAM
; Charizard team
	db TRI_ATTACK, SHARPEN, ICE_BEAM, THUNDERBOLT
	db BODY_SLAM, EARTHQUAKE, BLIZZARD, HYPER_BEAM
	db PSYCHIC_M, MEGA_DRAIN, SLEEP_POWDER, EGG_BOMB
	db FLAMETHROWER, BODY_SLAM, DIG, REFLECT
	db FLAMETHROWER, SLASH, EARTHQUAKE, REFLECT
	db SURF, BLIZZARD, THUNDERBOLT, HYPER_BEAM
ProfOakMoveSetsEnd:
	assert ProfOakMoveSetsEnd - ProfOakMoveSets == NUM_PROF_OAK_TEAMS * PROF_OAK_PARTY_LENGTH * NUM_MOVES

ChiefMoveSets:
	db PSYCHIC_M,  RECOVER,     REFLECT,      THUNDER_WAVE ; Alakazam
	db BODY_SLAM,  THUNDERBOLT, THUNDER_WAVE, METRONOME    ; Clefable
IF DEF(_RED)
	db EARTHQUAKE, BODY_SLAM,   ICE_BEAM,     THUNDERBOLT  ; Nidoqueen
	db WING_ATTACK, DOUBLE_EDGE, SWORDS_DANCE, QUICK_ATTACK ; Scyther
ENDC
IF DEF(_BLUE)
	db EARTHQUAKE, ROCK_SLIDE,  THUNDERBOLT,  THRASH       ; Nidoking
	db SUBMISSION, BODY_SLAM,   SWORDS_DANCE, SEISMIC_TOSS ; Pinsir
ENDC
	db SURF,       BLIZZARD,    THUNDERBOLT,  HYPER_BEAM   ; Dragonite
	db TRI_ATTACK, RECOVER,     ICE_BEAM,     THUNDERBOLT  ; Porygon
ChiefMoveSetsEnd:
	assert ChiefMoveSetsEnd - ChiefMoveSets == CHIEF_PARTY_LENGTH * NUM_MOVES

FightingDojoTrialMoveSetPointers:
	table_width 2
	dw FightingDojoTrialSwiftnessMoveSets
	dw FightingDojoTrialEnduranceMoveSets
	dw FightingDojoTrialMasteryMoveSets
	assert_table_length NUM_FIGHTING_DOJO_TRIAL_TEAMS

FightingDojoTrialSwiftnessMoveSets:
	db SLASH,         BUBBLEBEAM,  THUNDERBOLT,  SCREECH      ; Persian
	db SUBMISSION,    ROCK_SLIDE,  BODY_SLAM,    FOCUS_ENERGY ; Primeape
	db DRILL_PECK,    TRI_ATTACK,  AGILITY,      HYPER_BEAM   ; Dodrio
.end
	assert .end - FightingDojoTrialSwiftnessMoveSets == FIGHTING_DOJO_TRIAL_PARTY_LENGTH * NUM_MOVES

FightingDojoTrialEnduranceMoveSets:
	db SURF,          SUBMISSION,  HYPNOSIS,     BODY_SLAM    ; Poliwrath
	db BODY_SLAM,     EARTHQUAKE,  ROCK_SLIDE,   COUNTER      ; Kangaskhan
	db BODY_SLAM,     EARTHQUAKE,  BLIZZARD,     HYPER_BEAM   ; Snorlax
.end
	assert .end - FightingDojoTrialEnduranceMoveSets == FIGHTING_DOJO_TRIAL_PARTY_LENGTH * NUM_MOVES

FightingDojoTrialMasteryMoveSets:
	db SUBMISSION,    MEGA_PUNCH,  ICE_PUNCH,    THUNDERPUNCH ; Hitmonchan
	db HI_JUMP_KICK,  MEGA_KICK,   MEDITATE,     BODY_SLAM    ; Hitmonlee
	db SUBMISSION,    EARTHQUAKE,  ROCK_SLIDE,   BODY_SLAM    ; Machamp
.end
	assert .end - FightingDojoTrialMasteryMoveSets == FIGHTING_DOJO_TRIAL_PARTY_LENGTH * NUM_MOVES
