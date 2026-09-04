BillsSecretGarden_Script:
	call BillsSecretGardenLoadMap
	call BillsSecretGardenTryPikachuSkim
	call BillsSecretGardenCheckExit
	jp EnableAutoTextBoxDrawing

BillsSecretGardenTryPikachuSkim:
	CheckEvent EVENT_GOT_BILLS_GARDEN_PIKACHU
	ret nz
	CheckEvent EVENT_SAW_BILLS_GARDEN_PIKACHU_SKIM
	ret nz
	; Keep the whole crossing on screen and wait until the player stops walking.
	ld a, [wXCoord]
	sub 10
	cp 6
	ret nc
	ld a, [wYCoord]
	sub 2
	cp 5
	ret nc
	ld a, [wWalkCounter]
	and a
	ret nz
	ld a, [wJoyIgnore]
	and a
	ret nz
	ld a, [wWalkBikeSurfState]
	cp 2
	ret z
	ld a, [wFontLoaded]
	bit BIT_FONT_LOADED, a
	ret nz
	ld a, [wStatusFlags5]
	and (1 << BIT_SCRIPTED_NPC_MOVEMENT) | (1 << BIT_SCRIPTED_MOVEMENT_STATE)
	ret nz
	ld a, [wUpdateSpritesEnabled]
	cp 1
	ret nz
	; The gift's object ID is stable even when decorative objects are appended.
	assert BILLSSECRETGARDEN_PIKACHU == 1
	ldh a, [hSpriteIndex]
	push af
	ld a, [wMapSpriteData]
	push af
	ld a, PIKACHU
	call PlayCry
	ld a, 1
	ld [wSprite01StateData1MovementStatus], a
	ld a, BILLSSECRETGARDEN_PIKACHU
	ldh [hSpriteIndex], a
	ld de, BillsSecretGardenPikachuSkimMovement
	call MoveSprite
	ld c, 192
.wait
	push bc
	call UpdateSprites
	call DelayFrame
	pop bc
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	jr z, .finished
	dec c
	jr nz, .wait
	jr .restore ; An interrupted/off-screen sprite must never trap player input.
.finished
	SetEvent EVENT_SAW_BILLS_GARDEN_PIKACHU_SKIM
.restore
	ld hl, wStatusFlags5
	res BIT_SCRIPTED_NPC_MOVEMENT, [hl]
	xor a
	ld [wJoyIgnore], a
	ld [wNPCNumScriptedSteps], a
	ld [wSimulatedJoypadStatesIndex], a
	ld [wUnusedOverrideSimulatedJoypadStatesIndex], a
	ld [wSprite01StateData1YStepVector], a
	ld [wSprite01StateData1XStepVector], a
	ld [wSprite01StateData1IntraAnimFrameCounter], a
	ld [wSprite01StateData1AnimFrameCounter], a
	ld [wSprite01StateData2WalkAnimationCounter], a
	ld a, 3 + 4
	ld [wSprite01StateData2MapY], a
	ld a, 11 + 4
	ld [wSprite01StateData2MapX], a
	ld a, STAY
	ld [wSprite01StateData2MovementByte1], a
	ld a, 1
	ld [wSprite01StateData1MovementStatus], a
	ld a, SPRITE_FACING_RIGHT
	ld [wSprite01StateData1FacingDirection], a
	pop af
	ld [wMapSpriteData], a
	call UpdateSprites
	pop af
	ldh [hSpriteIndex], a
	ret

BillsSecretGardenPikachuSkimMovement:
	db NPC_MOVEMENT_RIGHT, NPC_MOVEMENT_RIGHT, NPC_MOVEMENT_RIGHT, NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_LEFT, NPC_MOVEMENT_LEFT, NPC_MOVEMENT_LEFT, NPC_MOVEMENT_LEFT
	db -1

BillsSecretGardenCheckExit:
	ld a, [wYCoord]
	cp 17
	ret nz
	ld a, [wXCoord]
	cp 14
	jr z, .leave
	cp 15
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
	dw_const BillsSecretGardenButterfreeText, TEXT_BILLSSECRETGARDEN_BUTTERFREE
	dw_const BillsSecretGardenPondText, TEXT_BILLSSECRETGARDEN_POND

BillsSecretGardenPikachuText:
	text_asm
	CheckEvent EVENT_SAW_BILLS_GARDEN_PIKACHU_SKIM
	ld hl, .WatchingPondText
	jr z, .greet
	ld hl, .SkimmedAcrossPondText
.greet
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

.WatchingPondText
	text "PIKACHU watches"
	line "the ripples..."
	done

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

BillsSecretGardenButterfreeText:
	text_asm
	ld a, BUTTERFREE
	call PlayCry
	call WaitForSoundToFinish
	ld hl, .FlowersText
	call PrintText
	jp TextScriptEnd

.FlowersText:
	text "BUTTERFREE flits"
	line "between flowers."
	done

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
	ld d, h
	ld e, l
	ld hl, .moves
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
	ld d, h
	ld e, l
	ld hl, .movePP
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
