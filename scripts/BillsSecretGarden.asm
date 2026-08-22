BillsSecretGarden_Script:
	call BillsSecretGardenLoadMap
	call BillsSecretGardenCheckExit
	jp EnableAutoTextBoxDrawing

BillsSecretGardenCheckExit:
	ld a, [wYCoord]
	cp 17
	ret nz
	ld a, [wXCoord]
	cp 8
	jr z, .leave
	cp 9
	ret nz
.leave
	ld a, ROUTE_25
	ldh [hWarpDestinationMap], a
	ld a, 1 ; destination-only return point (stored as index 1)
	ld [wDestinationWarpID], a
	ld hl, wStatusFlags3
	set BIT_FORCE_DESTINATION_WARP_POSITION, [hl]
	set BIT_WARP_FROM_CUR_SCRIPT, [hl]
	ret

BillsSecretGardenLoadMap:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	ld a, TOGGLE_BILLS_SECRET_GARDEN_PIKACHU
	ld [wToggleableObjectIndex], a
	CheckEvent EVENT_GOT_BILLS_GARDEN_PIKACHU
	jr nz, .hidePikachu
	predef_jump ShowObject
.hidePikachu
	predef_jump HideObject

BillsSecretGarden_TextPointers:
	def_text_pointers
	dw_const BillsSecretGardenPikachuText, TEXT_BILLSSECRETGARDEN_PIKACHU
	dw_const BillsSecretGardenNotebookText, TEXT_BILLSSECRETGARDEN_NOTEBOOK
	dw_const BillsSecretGardenChairText, TEXT_BILLSSECRETGARDEN_CHAIR
	dw_const BillsSecretGardenPondText, TEXT_BILLSSECRETGARDEN_POND

BillsSecretGardenPikachuText:
	text_asm
	ld hl, .SkimmedAcrossPondText
	call PrintText
	ld a, PIKACHU
	call PlayCry
	call WaitForSoundToFinish
	ld hl, .WantsToJoinText
	call PrintText
	lb bc, PIKACHU, 25
	call GivePokemon
	jr nc, .noRoom
	call BillsSecretGardenCustomizePikachu
	SetEvent EVENT_GOT_BILLS_GARDEN_PIKACHU
	ld a, TOGGLE_BILLS_SECRET_GARDEN_PIKACHU
	ld [wToggleableObjectIndex], a
	predef HideObject
	jp TextScriptEnd
.noRoom
	call WaitForTextScrollButtonPress
	call EnableAutoTextBoxDrawing
	ld hl, .WillWaitText
	call PrintText
	jp TextScriptEnd

.SkimmedAcrossPondText
	text_far _BillsSecretGardenPikachuSkimmedAcrossPondText
	text_end

.WantsToJoinText
	text_far _BillsSecretGardenPikachuWantsToJoinText
	text_end

.WillWaitText
	text_far _BillsSecretGardenPikachuWillWaitText
	text_end

BillsSecretGardenNotebookText:
	text_far _BillsSecretGardenNotebookText
	text_end

BillsSecretGardenChairText:
	text_asm
	call DisableWaitingAfterTextDisplay
	jp TextScriptEnd

BillsSecretGardenPondText:
	text_asm
	CheckEvent EVENT_GOT_BILLS_GARDEN_PIKACHU
	jr z, .rippling
	ld hl, .StillText
	call PrintText
	ld a, SFX_TELEPORT_ENTER_1
	call PlaySound
	call GBFadeOutToWhite
	call Delay3
	call GBFadeInFromWhite
	call WaitForSoundToFinish
	ld hl, .ReflectionText
	call PrintText
	jp TextScriptEnd
.rippling
	ld hl, .RipplesText
	call PrintText
	jp TextScriptEnd

.RipplesText:
	text_far _BillsSecretGardenPondRipplesText
	text_end

.StillText:
	text_far _BillsSecretGardenPondStillText
	text_end

.ReflectionText:
	text_far _BillsSecretGardenPondReflectionText
	text_end

BillsSecretGardenCustomizePikachu:
	ld a, [wAddedToParty]
	and a
	jr z, .boxed

	call .getLastPartyMon
	call .writeSpecialData

	ld a, PIKACHU
	ld [wCurSpecies], a
	call GetMonHeader
	ld a, 25
	ld [wCurEnemyLevel], a
	call .getLastPartyMon
	push hl
	ld bc, MON_MAXHP
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, MON_HP_EXP - 1
	add hl, bc
	ld b, 1
	call CalcStats

	call .getLastPartyMon
	push hl
	ld bc, MON_HP
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	ld bc, MON_MAXHP
	add hl, bc
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	ret

.boxed
	ld hl, wBoxMon1
	call .writeSpecialData
	ld a, PIKACHU
	ld [wCurSpecies], a
	call GetMonHeader
	ld a, 25
	ld [wCurEnemyLevel], a
	ld hl, wBoxMon1
	ld bc, MON_HP_EXP - 1
	add hl, bc
	ld b, 1
	ld c, 1 ; HP
	call CalcStat
	ld hl, wBoxMon1 + MON_HP
	ldh a, [hMultiplicand + 1]
	ld [hli], a
	ldh a, [hMultiplicand + 2]
	ld [hl], a
	ret

.writeSpecialData
	push hl
	ld bc, MON_MOVES
	add hl, bc
	ld de, .moves
	ld bc, NUM_MOVES
	call CopyData
	pop hl
	push hl
	ld bc, MON_DVS
	add hl, bc
	ld a, $ea ; shiny-compatible when traded to Generation II
	ld [hli], a
	ld [hl], $aa
	pop hl
	ld bc, MON_PP
	add hl, bc
	ld de, .movePP
	ld bc, NUM_MOVES
	jp CopyData

.getLastPartyMon
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1
	ld bc, PARTYMON_STRUCT_LENGTH
	jp AddNTimes

.moves
	db THUNDERBOLT, SURF, THUNDER_WAVE, QUICK_ATTACK

.movePP
	db 15, 15, 20, 30
