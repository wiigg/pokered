MrPsychicMoveServices::
	call SaveScreenTilesToBuffer2
	ld hl, .IntroText
	call PrintText
	call .DisplayServiceMenu
	ret c
	and a
	jr z, .rememberMove
	dec a
	jr z, .forgetMove
	ret

.rememberMove
	ld hl, .WhichPokemonRememberText
	call PrintText
	call .ChoosePartyMon
	ret c
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a
	call LoadMonData
	farcall BuildMoveReminderList
	ld a, [wItemList]
	and a
	jr z, .noMovesToRemember
	ld hl, .WhichMoveRememberText
	call PrintText
	call .ChooseMove
	jp c, .restoreAndReturn
	ld [wMoveNum], a
	call .RestoreMapAfterMenu
	ld a, [wMoveNum]
	ld [wNamedObjectIndex], a
	call GetMoveName
	call CopyToStringBuffer
	predef LearnMove
	ret

.noMovesToRemember
	ld hl, .NoMovesToRememberText
	jp PrintText

.forgetMove
	ld hl, .WhichPokemonForgetText
	call PrintText
	call .ChoosePartyMon
	ret c
	call .BuildKnownMoveList
	ld a, [wItemList]
	cp 2
	jr c, .onlyOneMove
	ld hl, .WhichMoveForgetText
	call PrintText
	call .ChooseMove
	jr c, .restoreAndReturn
	ld [wMoveNum], a
	ld a, c
	ld [wMoveMenuType], a
	call .RestoreMapAfterMenu

	ld a, [wMoveNum]
	ld [wNamedObjectIndex], a
	call GetMoveName
	call CopyToStringBuffer
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, wNameBuffer
	ld de, wLearnMoveMonName
	ld bc, NAME_LENGTH
	call CopyData
	ld hl, .ConfirmForgetText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ret nz
	call .DeleteSelectedMove
	ld a, SFX_SWAP
	call PlaySoundWaitForCurrent
	ld hl, .ForgotMoveText
	jp PrintText

.onlyOneMove
	ld hl, .OnlyOneMoveText
	jp PrintText

.restoreAndReturn
	jp .RestoreMapAfterMenu

.DisplayServiceMenu
	call SaveScreenTilesToBuffer1
	hlcoord 8, 8
	lb bc, 7, 10
	call TextBoxBorder
	hlcoord 10, 10
	ld de, .MenuEntries
	call PlaceString
	ld hl, wTopMenuItemY
	ld a, 10
	ld [hli], a
	ld a, 9
	ld [hli], a
	xor a
	ld [hli], a
	inc hl
	ld a, 2
	ld [hli], a
	ld a, PAD_A | PAD_B
	ld [hli], a
	xor a
	ld [hl], a
	ld [wMenuWatchMovingOutOfBounds], a
	call HandleMenuInput
	push af
	call LoadScreenTilesFromBuffer1
	pop af
	bit B_PAD_B, a
	jr nz, .cancelService
	ld a, [wCurrentMenuItem]
	cp 2
	jr z, .cancelService
	and a
	ret
.cancelService
	scf
	ret

.ChoosePartyMon
	xor a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wUpdateSpritesEnabled], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	push af
	call .RestoreMapAfterMenu
	pop af
	ret

.ChooseMove
	ld a, [wWhichPokemon]
	push af
	xor a
	ld [wCurrentMenuItem], a
	ld [wListScrollOffset], a
	ld [wPrintItemPrices], a
	ld [wMenuItemToSwap], a
	ld hl, wItemList
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	ld a, MOVESLISTMENU
	ld [wListMenuID], a
	call DisplayListMenuID
	jr c, .cancelMove
	ld a, [wWhichPokemon]
	ld c, a
	ld a, [wCurListMenuItem]
	ld b, a
	xor a
	ld [wListScrollOffset], a
	pop af
	ld [wWhichPokemon], a
	ld a, b
	and a
	ret
.cancelMove
	xor a
	ld [wListScrollOffset], a
	pop af
	ld [wWhichPokemon], a
	scf
	ret

.BuildKnownMoveList
	xor a
	ld [wItemList], a
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld de, wItemList + 1
	ld b, NUM_MOVES
.knownMoveLoop
	ld a, [hli]
	and a
	jr z, .nextKnownMove
	ld [de], a
	inc de
	ld a, [wItemList]
	inc a
	ld [wItemList], a
.nextKnownMove
	dec b
	jr nz, .knownMoveLoop
	ld a, -1
	ld [de], a
	ret

.DeleteSelectedMove
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [wMoveMenuType]
	ld c, a
	ld b, 0
	add hl, bc
	call .ShiftMoveDataLeft
	ld hl, wPartyMon1PP
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [wMoveMenuType]
	ld c, a
	ld b, 0
	add hl, bc
.ShiftMoveDataLeft
	ld a, [wMoveMenuType]
	ld b, a
	ld a, NUM_MOVES - 1
	sub b
	ld b, a
	ld d, h
	ld e, l
	inc hl
.shiftLoop
	ld a, b
	and a
	jr z, .clearLastSlot
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr .shiftLoop
.clearLastSlot
	xor a
	ld [de], a
	ret

.RestoreMapAfterMenu
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	jp LoadGBPal

.IntroText:
	text_far _MrPsychicsHouseMrPsychicMoveServiceIntroText
	text_end

.WhichPokemonRememberText:
	text_far _MrPsychicsHouseWhichPokemonRememberText
	text_end

.WhichMoveRememberText:
	text_far _MrPsychicsHouseWhichMoveRememberText
	text_end

.NoMovesToRememberText:
	text_far _MrPsychicsHouseNoMovesToRememberText
	text_end

.WhichPokemonForgetText:
	text_far _MrPsychicsHouseWhichPokemonForgetText
	text_end

.WhichMoveForgetText:
	text_far _MrPsychicsHouseWhichMoveForgetText
	text_end

.OnlyOneMoveText:
	text_far _MrPsychicsHouseOnlyOneMoveText
	text_end

.ConfirmForgetText:
	text_far _MrPsychicsHouseConfirmForgetText
	text_end

.ForgotMoveText:
	text_far _MrPsychicsHouseForgotMoveText
	text_end

.MenuEntries:
	db   "REMEMBER"
	next "FORGET"
	next "CANCEL@"
