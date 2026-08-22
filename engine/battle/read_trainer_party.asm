ReadTrainer:

; don't change any moves in a link battle
	ld a, [wLinkState]
	and a
	ret nz

; set [wEnemyPartyCount] to 0, [wEnemyPartySpecies] to FF
; XXX first is total enemy pokemon?
; XXX second is species of first pokemon?
	ld hl, wEnemyPartyCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a

; get the pointer to trainer data for this class
	ld a, [wCurOpponent]
	sub OPP_ID_OFFSET + 1 ; convert value from pokemon to trainer
	add a
	ld hl, TrainerDataPointers
	ld c, a
	ld b, 0
	add hl, bc ; hl points to trainer class
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wTrainerNo]
	ld b, a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.CheckNextTrainer
	dec b
	jr z, .IterateTrainer
.SkipTrainer
	ld a, [hli]
	and a
	jr nz, .SkipTrainer
	jr .CheckNextTrainer

; if the first byte of trainer data is FF,
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - major trainers can have complete custom movesets
; else the first byte is the level of every pokemon on the team
.IterateTrainer
	ld a, [hli]
	cp $FF ; is the trainer special?
	jr z, .SpecialTrainer ; if so, check for special moves
	ld [wCurEnemyLevel], a
.LoopTrainerData
	ld a, [hli]
	and a ; have we reached the end of the trainer data?
	jp z, .FinishUp
	ld [wCurPartySpecies], a
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	push hl
	call AddPartyMon
	pop hl
	jr .LoopTrainerData
.SpecialTrainer
; if this code is being run:
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
	ld a, [hli]
	and a ; have we reached the end of the trainer data?
	jr z, .AddGymLeaderMoves
	ld [wCurEnemyLevel], a
	ld a, [hli]
	ld [wCurPartySpecies], a
	ld a, ENEMY_PARTY_DATA
	ld [wMonDataLocation], a
	push hl
	call AddPartyMon
	pop hl
	jr .SpecialTrainer
.AddGymLeaderMoves
	ld a, [wGymLeaderNo]
	and a
	jr z, .AddTeamMove
	dec a
	add a
	ld c, a
	ld b, 0
	ld hl, GymLeaderMoveSetPointers
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wEnemyPartyCount]
	ld b, a
	jp .GiveFullTeamMoves
.AddTeamMove
; check if our trainer's team has special moves

; get trainer class number
	ld a, [wCurOpponent]
	sub OPP_ID_OFFSET
	ld b, a
	cp RIVAL1
	jr z, .GiveRivalMoves
	cp RIVAL2
	jr z, .GiveRivalMoves
	cp CHIEF
	jr z, .GiveChiefMoves
	cp PROF_OAK
	jr z, .GiveProfOakMoves
	cp RIVAL3
	jr z, .GiveBossMoves
	cp LORELEI
	jr z, .GiveBossMoves
	cp BRUNO
	jr z, .GiveBossMoves
	cp AGATHA
	jr z, .GiveBossMoves
	cp LANCE
	jr z, .GiveBossMoves
	jr .FinishUp
.GiveRivalMoves
	farcall GiveRivalMoves
	jr .FinishUp
.GiveBossMoves
	farcall GiveBossMoves
	jr .FinishUp
.GiveChiefMoves
	ld hl, ChiefMoveSets
	ld b, CHIEF_PARTY_LENGTH
	jr .GiveFullTeamMoves
.GiveProfOakMoves
	ld a, [wTrainerNo]
	dec a
	ld hl, ProfOakMoveSets
	ld bc, PROF_OAK_PARTY_LENGTH * NUM_MOVES
	call AddNTimes
	ld b, PROF_OAK_PARTY_LENGTH
.GiveFullTeamMoves
	push bc
	ld de, wEnemyMon1Moves
.copyTrainerMonMoves
	ld c, NUM_MOVES
.copyTrainerMove
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copyTrainerMove
	ld c, PARTYMON_STRUCT_LENGTH - NUM_MOVES
.nextTrainerMon
	inc de
	dec c
	jr nz, .nextTrainerMon
	dec b
	jr nz, .copyTrainerMonMoves
	pop bc
	ld hl, wEnemyMon1Moves
	ld de, wEnemyMon1PP - 1
.loadTrainerMovePPs
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
	jr nz, .loadTrainerMovePPs
.FinishUp
; clear wAmountMoneyWon addresses
	xor a
	ld de, wAmountMoneyWon
	ld [de], a
	inc de
	ld [de], a
	inc de
	ld [de], a
	ld a, [wCurEnemyLevel]
	ld b, a
.LastLoop
; update wAmountMoneyWon addresses (money to win) based on enemy's level
	ld hl, wTrainerBaseMoney + 1
	ld c, 2 ; wAmountMoneyWon is a 3-byte number
	push bc
	predef AddBCDPredef
	pop bc
	inc de
	inc de
	dec b
	jr nz, .LastLoop ; repeat wCurEnemyLevel times
	ret
