GiveRivalMoves::
	ld a, [wCurOpponent]
	sub OPP_ID_OFFSET
	cp RIVAL1
	jr z, .rival1
	cp RIVAL2
	ret nz

	ld a, [wTrainerNo]
	dec a
	ld hl, Rival2MoveSetPointers
	jr .loadMoveSet

.rival1
	ld a, [wTrainerNo]
	; Lab teams use the normal generated moves path.
	cp 4
	ret c
	sub 4
	ld hl, Rival1MoveSetPointers

.loadMoveSet
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [wEnemyPartyCount]
	ld b, a
	jp GiveTrainerMoves

GiveBossMoves::
	ld a, [wCurOpponent]
	sub OPP_ID_OFFSET
	cp LORELEI
	jr z, .lorelei
	cp BRUNO
	jr z, .bruno
	cp AGATHA
	jr z, .agatha
	cp LANCE
	jr z, .lance
	cp RIVAL3
	ret nz

	ld a, [wTrainerNo]
	dec a
	add a
	ld c, a
	ld b, 0
	ld hl, ChampionMoveSetPointers
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, PARTY_LENGTH
	jp GiveTrainerMoves

.lorelei
	ld hl, LoreleiMoveSets
	jr .eliteFour
.bruno
	ld hl, BrunoMoveSets
	jr .eliteFour
.agatha
	ld hl, AgathaMoveSets
	jr .eliteFour
.lance
	ld hl, LanceMoveSets
.eliteFour
	ld b, ELITE_FOUR_PARTY_LENGTH
	; fallthrough

GiveTrainerMoves:
	push bc
	ld de, wEnemyMon1Moves
.copyMonMoves
	ld c, NUM_MOVES
.copyMove
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copyMove
	ld c, PARTYMON_STRUCT_LENGTH - NUM_MOVES
.nextMon
	inc de
	dec c
	jr nz, .nextMon
	dec b
	jr nz, .copyMonMoves

	pop bc
	ld hl, wEnemyMon1Moves
	ld de, wEnemyMon1PP - 1
.loadMovePPs
	push bc
	push hl
	push de
	predef LoadMovePPs
	pop de
	pop hl
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	push hl
	ld h, d
	ld l, e
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	pop bc
	dec b
	jr nz, .loadMovePPs
	ret

INCLUDE "data/trainers/rival_moves.asm"
INCLUDE "data/trainers/boss_moves.asm"
