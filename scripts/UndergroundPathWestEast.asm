UndergroundPathWestEast_Script:
	call UndergroundPathWestEastUpdateRocketDeserter
	call EnableAutoTextBoxDrawing
	ld hl, UndergroundPathWestEastTrainerHeaders
	ld de, UndergroundPathWestEast_ScriptPointers
	ld a, [wUndergroundPathWestEastCurScript]
	call ExecuteCurMapScriptInTable
	ld [wUndergroundPathWestEastCurScript], a
	ret

UndergroundPathWestEastUpdateRocketDeserter:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI
	jr z, .hide
	CheckEvent EVENT_BEAT_SILPH_CO_GIOVANNI
	jr nz, .hide
	CheckEvent EVENT_BEAT_UNDERGROUND_PATH_ROCKET_DESERTER
	jr nz, .hide
	ld a, [wXCoord]
	cp 34
	jr nz, .show
	ld a, [wYCoord]
	cp 1
	jr z, .hide
.show
	ld a, TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER
	ld [wToggleableObjectIndex], a
	predef_jump ShowObject
.hide
	ld a, TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER
	ld [wToggleableObjectIndex], a
	predef_jump HideObject

UndergroundPathWestEast_ScriptPointers:
	def_script_pointers
	dw_const UndergroundPathWestEastDefaultScript, SCRIPT_UNDERGROUNDPATHWESTEAST_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_UNDERGROUNDPATHWESTEAST_START_BATTLE
	dw_const UndergroundPathWestEastRocketDeserterPostBattleScript, SCRIPT_UNDERGROUNDPATHWESTEAST_ROCKET_DESERTER_POST_BATTLE

UndergroundPathWestEastDefaultScript:
	CheckEvent EVENT_HEARD_UNDERGROUND_PATH_PHANTOM_TRAIN
	jr nz, .checkTrainers
	ld hl, .PhantomTrainTriggerCoords
	call ArePlayerCoordsInArray
	jr nc, .checkTrainers

	xor a
	ldh [hJoyHeld], a
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, SFX_STOP_ALL_MUSIC
	call PlaySound
	ld c, 15
	call DelayFrames

	ld b, 3
	predef ChangeBGPalColor0_4Frames
	ld c, 6
	call DelayFrames
	ld b, 3
	predef ChangeBGPalColor0_4Frames
	ld a, SFX_SS_ANNE_HORN
	call PlaySound
	ld c, 15
	call DelayFrames
	ld a, SFX_PUSH_BOULDER
	call PlaySound
	ld b, 5
	predef PredefShakeScreenHorizontally
	ld b, 2
	predef ChangeBGPalColor0_4Frames
	call WaitForSoundToFinish

	ld a, TEXT_UNDERGROUNDPATHWESTEAST_PHANTOM_TRAIN
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_HEARD_UNDERGROUND_PATH_PHANTOM_TRAIN
	call PlayDefaultMusic
	xor a
	ld [wJoyIgnore], a
.checkTrainers
	jp CheckFightingMapTrainers

.PhantomTrainTriggerCoords:
	dbmapcoord 24, 1
	dbmapcoord 24, 2
	dbmapcoord 24, 3
	dbmapcoord 24, 4
	dbmapcoord 24, 5
	db -1 ; end

UndergroundPathWestEastRocketDeserterPostBattleScript:
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jr z, UndergroundPathWestEastResetScript
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TEXT_UNDERGROUNDPATHWESTEAST_ROCKET_DESERTER_WARNING
	ldh [hTextID], a
	call DisplayTextID
	ld a, SFX_RUN
	call PlaySound
	call GBFadeOutToWhite
	ld a, TOGGLE_UNDERGROUND_PATH_ROCKET_DESERTER
	ld [wToggleableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromWhite
	call WaitForSoundToFinish
	ld hl, UndergroundPathWestEastRocketDeserterVanishedText
	call PrintText
	; fall through

UndergroundPathWestEastResetScript:
	xor a
	ld [wJoyIgnore], a
	ld [wUndergroundPathWestEastCurScript], a
	ld [wCurMapScript], a
	ret

UndergroundPathWestEast_TextPointers:
	def_text_pointers
	dw_const UndergroundPathWestEastRocketDeserterText, TEXT_UNDERGROUNDPATHWESTEAST_ROCKET_DESERTER
	dw_const UndergroundPathWestEastRocketDeserterWarningText, TEXT_UNDERGROUNDPATHWESTEAST_ROCKET_DESERTER_WARNING
	dw_const UndergroundPathWestEastPhantomTrainText, TEXT_UNDERGROUNDPATHWESTEAST_PHANTOM_TRAIN

UndergroundPathWestEastRocketDeserterText:
	text_asm
	ld hl, UndergroundPathWestEastRocketDeserterTrainerHeader
	call TalkToTrainer
	jp TextScriptEnd

UndergroundPathWestEastRocketDeserterWarningText:
	text_far _UndergroundPathWestEastRocketDeserterWarningText
	text_end

UndergroundPathWestEastRocketDeserterVanishedText:
	text_far _UndergroundPathWestEastRocketDeserterVanishedText
	text_end

UndergroundPathWestEastPhantomTrainText:
	text_far _UndergroundPathWestEastPhantomTrainText
	text_end

UndergroundPathWestEastTrainerHeaders:
	def_trainers 2
UndergroundPathWestEastRocketDeserterTrainerHeader:
	trainer EVENT_BEAT_UNDERGROUND_PATH_ROCKET_DESERTER, 4, UndergroundPathWestEastRocketDeserterBattleText, UndergroundPathWestEastRocketDeserterEndBattleText, UndergroundPathWestEastRocketDeserterAfterBattleText
	db -1 ; end

UndergroundPathWestEastRocketDeserterBattleText:
	text_far _UndergroundPathWestEastRocketDeserterBattleText
	text_end

UndergroundPathWestEastRocketDeserterEndBattleText:
	text_far _UndergroundPathWestEastRocketDeserterEndBattleText
	text_end

UndergroundPathWestEastRocketDeserterAfterBattleText:
	text_far _UndergroundPathWestEastRocketDeserterAfterBattleText
	text_end
