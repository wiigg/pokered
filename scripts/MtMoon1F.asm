MtMoon1F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, MtMoon1TrainerHeaders
	ld de, MtMoon1F_ScriptPointers
	ld a, [wMtMoon1FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wMtMoon1FCurScript], a
	ret

MtMoon1F_ScriptPointers:
	def_script_pointers
	dw_const MtMoon1FDefaultScript,                 SCRIPT_MTMOON1F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_MTMOON1F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_MTMOON1F_END_BATTLE

MtMoon1FDefaultScript:
	call CheckFightingMapTrainers
	ld a, [wCurMapScript]
	and a
	ret nz
	CheckEvent EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY
	ret nz
	CheckEvent EVENT_HEARD_MT_MOON_MOONFALL_RUMBLE
	ret nz
	CheckEvent EVENT_BEAT_MT_MOON_EXIT_SUPER_NERD
	ret z
	ld a, [wToggleableObjectFlags + (TOGGLE_MT_MOON_1F_ITEM_2 / 8)]
	bit TOGGLE_MT_MOON_1F_ITEM_2 % 8, a
	ret z

	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	xor a
	ldh [hJoyHeld], a
	ld a, SFX_PUSH_BOULDER
	call PlaySound
	ld b, 3
	predef PredefShakeScreenHorizontally
	ld a, CLEFAIRY
	call PlayCry
	call WaitForSoundToFinish
	ld a, TEXT_MTMOON1F_MOONFALL_RUMBLE
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_HEARD_MT_MOON_MOONFALL_RUMBLE
	xor a
	ld [wJoyIgnore], a
	ret

MtMoon1F_TextPointers:
	def_text_pointers
	dw_const MtMoon1FHikerText,         TEXT_MTMOON1F_HIKER
	dw_const MtMoon1FYoungster1Text,    TEXT_MTMOON1F_YOUNGSTER1
	dw_const MtMoon1FCooltrainerF1Text, TEXT_MTMOON1F_COOLTRAINER_F1
	dw_const MtMoon1FSuperNerdText,     TEXT_MTMOON1F_SUPER_NERD
	dw_const MtMoon1FCooltrainerF2Text, TEXT_MTMOON1F_COOLTRAINER_F2
	dw_const MtMoon1FYoungster2Text,    TEXT_MTMOON1F_YOUNGSTER2
	dw_const MtMoon1FYoungster3Text,    TEXT_MTMOON1F_YOUNGSTER3
	dw_const PickUpItemText,            TEXT_MTMOON1F_POTION1
	dw_const PickUpItemText,            TEXT_MTMOON1F_MOON_STONE
	dw_const PickUpItemText,            TEXT_MTMOON1F_RARE_CANDY
	dw_const PickUpItemText,            TEXT_MTMOON1F_ESCAPE_ROPE
	dw_const PickUpItemText,            TEXT_MTMOON1F_POTION2
	dw_const PickUpItemText,            TEXT_MTMOON1F_TM_WATER_GUN
	dw_const MtMoon1FClefairyText,      TEXT_MTMOON1F_CLEFAIRY1
	dw_const MtMoon1FClefairyText,      TEXT_MTMOON1F_CLEFAIRY2
	dw_const MtMoon1FMoonfallSiteText,  TEXT_MTMOON1F_MOONFALL_SITE
	dw_const MtMoon1FBewareZubatSign,   TEXT_MTMOON1F_BEWARE_ZUBAT_SIGN
	dw_const MtMoon1FMoonfallRumbleText, TEXT_MTMOON1F_MOONFALL_RUMBLE

MtMoon1TrainerHeaders:
	def_trainers
MtMoon1TrainerHeader0:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_0, 2, MtMoon1FHikerBattleText, MtMoon1FHikerEndBattleText, MtMoon1FHikerAfterBattleText
MtMoon1TrainerHeader1:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_1, 3, MtMoon1FYoungster1BattleText, MtMoon1FYoungster1EndBattleText, MtMoon1FYoungster1AfterBattleText
MtMoon1TrainerHeader2:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_2, 3, MtMoon1FCooltrainerF1BattleText, MtMoon1FCooltrainerF1EndBattleText, MtMoon1FCooltrainerF1AfterBattleText
MtMoon1TrainerHeader3:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_3, 3, MtMoon1FSuperNerdBattleText, MtMoon1FSuperNerdEndBattleText, MtMoon1FSuperNerdAfterBattleText
MtMoon1TrainerHeader4:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_4, 3, MtMoon1FCooltrainerF2BattleText, MtMoon1FCooltrainerF2EndBattleText, MtMoon1FCooltrainerF2AfterBattleText
MtMoon1TrainerHeader5:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_5, 3, MtMoon1FYoungster2BattleText, MtMoon1FYoungster2EndBattleText, MtMoon1FYoungster2AfterBattleText
MtMoon1TrainerHeader6:
	trainer EVENT_BEAT_MT_MOON_1_TRAINER_6, 3, MtMoon1FYoungster3BattleText, MtMoon1FYoungster3EndBattleText, MtMoon1FYoungster3AfterBattleText
	db -1 ; end

MtMoon1FHikerText:
	text_asm
	ld hl, MtMoon1TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FYoungster1Text:
	text_asm
	ld hl, MtMoon1TrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FCooltrainerF1Text:
	text_asm
	ld hl, MtMoon1TrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FSuperNerdText:
	text_asm
	ld hl, MtMoon1TrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FCooltrainerF2Text:
	text_asm
	ld hl, MtMoon1TrainerHeader4
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FYoungster2Text:
	text_asm
	ld hl, MtMoon1TrainerHeader5
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FYoungster3Text:
	text_asm
	ld hl, MtMoon1TrainerHeader6
	call TalkToTrainer
	jp TextScriptEnd

MtMoon1FHikerBattleText:
	text_far _MtMoon1FHikerBattleText
	text_end

MtMoon1FHikerEndBattleText:
	text_far _MtMoon1FHikerEndBattleText
	text_end

MtMoon1FHikerAfterBattleText:
	text_far _MtMoon1FHikerAfterBattleText
	text_end

MtMoon1FYoungster1BattleText:
	text_far _MtMoon1FYoungster1BattleText
	text_end

MtMoon1FYoungster1EndBattleText:
	text_far _MtMoon1FYoungster1EndBattleText
	text_end

MtMoon1FYoungster1AfterBattleText:
	text_far _MtMoon1FYoungster1AfterBattleText
	text_end

MtMoon1FCooltrainerF1BattleText:
	text_far _MtMoon1FCooltrainerF1BattleText
	text_end

MtMoon1FCooltrainerF1EndBattleText:
	text_far _MtMoon1FCooltrainerF1EndBattleText
	text_end

MtMoon1FCooltrainerF1AfterBattleText:
	text_far _MtMoon1FCooltrainerF1AfterBattleText
	text_end

MtMoon1FSuperNerdBattleText:
	text_far _MtMoon1FSuperNerdBattleText
	text_end

MtMoon1FSuperNerdEndBattleText:
	text_far _MtMoon1FSuperNerdEndBattleText
	text_end

MtMoon1FSuperNerdAfterBattleText:
	text_far _MtMoon1FSuperNerdAfterBattleText
	text_end

MtMoon1FCooltrainerF2BattleText:
	text_far _MtMoon1FCooltrainerF2BattleText
	text_end

MtMoon1FCooltrainerF2EndBattleText:
	text_far _MtMoon1FCooltrainerF2EndBattleText
	text_end

MtMoon1FCooltrainerF2AfterBattleText:
	text_far _MtMoon1FCooltrainerF2AfterBattleText
	text_end

MtMoon1FYoungster2BattleText:
	text_far _MtMoon1FYoungster2BattleText
	text_end

MtMoon1FYoungster2EndBattleText:
	text_far _MtMoon1FYoungster2EndBattleText
	text_end

MtMoon1FYoungster2AfterBattleText:
	text_far _MtMoon1FYoungster2AfterBattleText
	text_end

MtMoon1FYoungster3BattleText:
	text_far _MtMoon1FYoungster3BattleText
	text_end

MtMoon1FYoungster3EndBattleText:
	text_far _MtMoon1FYoungster3EndBattleText
	text_end

MtMoon1FYoungster3AfterBattleText:
	text_far _MtMoon1FYoungster3AfterBattleText
	text_end

MtMoon1FMoonfallSiteText:
	text_asm
	CheckEvent EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY
	jr nz, .ceremony_complete
	CheckEvent EVENT_BEAT_MT_MOON_EXIT_SUPER_NERD
	jr z, .quiet
	ld a, [wToggleableObjectFlags + (TOGGLE_MT_MOON_1F_ITEM_2 / 8)]
	bit TOGGLE_MT_MOON_1F_ITEM_2 % 8, a
	jr z, .quiet

	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	call GBFadeOutToWhite
	call MtMoon1FShowMoonfallClefairy
	call GBFadeInFromWhite
	ld hl, MtMoon1FMoonfallBeginsText
	call PrintText
	ld a, CLEFAIRY
	call PlayCry
	call WaitForSoundToFinish
	call MtMoon1FAnimateMoonfallDance
	ld hl, MtMoon1FMoonfallDanceText
	call PrintText
	call GBFadeOutToWhite
	call MtMoon1FHideMoonfallClefairy
	call GBFadeInFromWhite
	ld hl, MtMoon1FMoonfallGiftText
	call PrintText
	lb bc, MOON_STONE, 1
	call GiveItem
	jr nc, .bag_full
	SetEvent EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY
	ld hl, MtMoon1FReceivedMoonStoneText
	call PrintText
	jr .unlock

.bag_full
	ld hl, MtMoon1FMoonfallBagFullText
	call PrintText
.unlock
	xor a
	ld [wJoyIgnore], a
	jp TextScriptEnd

.ceremony_complete
	ld hl, MtMoon1FMoonfallCompleteText
	call PrintText
	jp TextScriptEnd

.quiet
	ld hl, MtMoon1FMoonfallQuietText
	call PrintText
	jp TextScriptEnd

MtMoon1FShowMoonfallClefairy:
	ld a, MTMOON1F_CLEFAIRY1
	lb bc, 2, 4
	call MtMoon1FSetCeremonySpritePosition
	ld a, MTMOON1F_CLEFAIRY2
	lb bc, 3, 3
	call MtMoon1FSetCeremonySpritePosition
	jp UpdateSprites

MtMoon1FHideMoonfallClefairy:
	ld a, MTMOON1F_CLEFAIRY1
	lb bc, -4, -4
	call MtMoon1FSetCeremonySpritePosition
	ld a, MTMOON1F_CLEFAIRY2
	lb bc, -4, -4
	call MtMoon1FSetCeremonySpritePosition
	jp UpdateSprites

; Places an object at map coordinate (c, b), including its current screen position.
MtMoon1FSetCeremonySpritePosition:
	ld [wSpriteIndex], a
	ld a, b
	add 4
	ldh [hSpriteMapYCoord], a
	ld d, a
	ld a, [wYCoord]
	ld e, a
	ld a, d
	sub e
	swap a
	sub 4
	ldh [hSpriteScreenYCoord], a
	ld a, c
	add 4
	ldh [hSpriteMapXCoord], a
	ld d, a
	ld a, [wXCoord]
	ld e, a
	ld a, d
	sub e
	swap a
	ldh [hSpriteScreenXCoord], a
	jp SetSpritePosition1

MtMoon1FAnimateMoonfallDance:
	ld a, MTMOON1F_CLEFAIRY1
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_DOWN
	ldh [hSpriteFacingDirection], a
	call MtMoon1FTurnCeremonySprite
	ld a, MTMOON1F_CLEFAIRY2
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_RIGHT
	ldh [hSpriteFacingDirection], a
	call MtMoon1FTurnCeremonySprite
	ld a, MTMOON1F_CLEFAIRY1
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_LEFT
	ldh [hSpriteFacingDirection], a
	call MtMoon1FTurnCeremonySprite
	ld a, MTMOON1F_CLEFAIRY2
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_UP
	ldh [hSpriteFacingDirection], a
	call MtMoon1FTurnCeremonySprite
	ld a, CLEFAIRY
	call PlayCry
	jp WaitForSoundToFinish

MtMoon1FTurnCeremonySprite:
	call SetSpriteFacingDirection
	call UpdateSprites
	ld c, 6
	jp DelayFrames

MtMoon1FMoonfallBeginsText:
	text_far _MtMoon1FMoonfallBeginsText
	text_end

MtMoon1FMoonfallDanceText:
	text_far _MtMoon1FMoonfallDanceText
	text_end

MtMoon1FMoonfallGiftText:
	text_far _MtMoon1FMoonfallGiftText
	text_end

MtMoon1FReceivedMoonStoneText:
	text_far _MtMoon1FReceivedMoonStoneText
	sound_get_item_1
	text_end

MtMoon1FMoonfallBagFullText:
	text_far _MtMoon1FMoonfallBagFullText
	text_end

MtMoon1FMoonfallCompleteText:
	text_far _MtMoon1FMoonfallCompleteText
	text_end

MtMoon1FMoonfallQuietText:
	text_far _MtMoon1FMoonfallQuietText
	text_end

MtMoon1FClefairyText:
	text_far _MtMoon1FClefairyText
	text_end

MtMoon1FBewareZubatSign:
	text_far _MtMoon1FBewareZubatSign
	text_end

MtMoon1FMoonfallRumbleText:
	text_far _MtMoon1FMoonfallRumbleText
	text_end
