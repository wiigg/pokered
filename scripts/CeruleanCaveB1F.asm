CeruleanCaveB1F_Script:
	call EnableAutoTextBoxDrawing
	call CeruleanCaveB1FCheckWandererEncounter
	ld hl, CeruleanCaveB1FTrainerHeaders
	ld de, CeruleanCaveB1F_ScriptPointers
	ld a, [wCeruleanCaveB1FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCeruleanCaveB1FCurScript], a
	ret

CeruleanCaveB1FCheckWandererEncounter:
	CheckEvent EVENT_MET_WANDERER_CERULEAN_CAVE
	ret nz
	ld a, [wCeruleanCaveB1FCurScript]
	and a
	ret nz
	ld hl, .PlayerCoords
	call ArePlayerCoordsInArray
	ret nc
	xor a
	ldh [hJoyHeld], a
	ld a, [wXCoord]
	cp 25
	jr z, .faceLeft
	ld a, [wYCoord]
	cp 14
	jr z, .sameRow
	jr c, .faceUp
	ld a, SPRITE_FACING_DOWN
	jr .setFacing
.faceUp
	ld a, SPRITE_FACING_UP
	jr .setFacing
.sameRow
	ld a, [wXCoord]
	cp 27
	jr c, .faceLeft
	jr z, .faceDown
	ld a, SPRITE_FACING_RIGHT
	jr .setFacing
.faceLeft
	ld a, SPRITE_FACING_LEFT
	jr .setFacing
.faceDown
	ld a, SPRITE_FACING_DOWN
.setFacing
	ld [wSprite04StateData1FacingDirection], a
	ld a, TEXT_CERULEANCAVEB1F_WANDERER
	ldh [hTextID], a
	jp DisplayTextID

.PlayerCoords:
	dbmapcoord 25, 13
	dbmapcoord 26, 13
	dbmapcoord 27, 13
	dbmapcoord 28, 13
	dbmapcoord 25, 14
	dbmapcoord 26, 14
	dbmapcoord 27, 14
	dbmapcoord 28, 14
	dbmapcoord 25, 15
	dbmapcoord 26, 15
	dbmapcoord 27, 15
	dbmapcoord 28, 15
	db -1 ; end

CeruleanCaveB1F_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_CERULEANCAVEB1F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_CERULEANCAVEB1F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_CERULEANCAVEB1F_END_BATTLE

CeruleanCaveB1F_TextPointers:
	def_text_pointers
	dw_const CeruleanCaveB1FMewtwoText, TEXT_CERULEANCAVEB1F_MEWTWO
	dw_const PickUpItemText,            TEXT_CERULEANCAVEB1F_ULTRA_BALL
	dw_const PickUpItemText,            TEXT_CERULEANCAVEB1F_MAX_REVIVE
	dw_const CeruleanCaveB1FWandererText, TEXT_CERULEANCAVEB1F_WANDERER

CeruleanCaveB1FTrainerHeaders:
	def_trainers
MewtwoTrainerHeader:
	trainer EVENT_BEAT_MEWTWO, 0, MewtwoBattleText, MewtwoBattleText, MewtwoBattleText
	db -1 ; end

CeruleanCaveB1FMewtwoText:
	text_asm
	ld hl, MewtwoTrainerHeader
	call TalkToTrainer
	jp TextScriptEnd

CeruleanCaveB1FWandererText:
	text_asm
	ld hl, .Text
	call PrintText
	CheckEvent EVENT_BEAT_MEWTWO
	ld hl, .MewtwoAheadText
	jr z, .printEnding
	ld hl, .AfterMewtwoText
.printEnding
	call PrintText
	ld a, SFX_TELEPORT_ENTER_1
	call PlaySound
	call GBFadeOutToWhite
	SetEvent EVENT_MET_WANDERER_CERULEAN_CAVE
	ld a, TOGGLE_CERULEAN_CAVE_B1F_WANDERER
	ld [wToggleableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromWhite
	call WaitForSoundToFinish
	jp TextScriptEnd

.Text:
	text_far _WandererCeruleanCaveText
	text_end

.MewtwoAheadText:
	text_far _WandererCeruleanCaveMewtwoAheadText
	text_end

.AfterMewtwoText:
	text_far _WandererCeruleanCaveAfterMewtwoText
	text_end

MewtwoBattleText:
	text_far _MewtwoBattleText
	text_asm
	ld a, MEWTWO
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd
