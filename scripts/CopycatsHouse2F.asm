CopycatsHouse2F_Script:
	call EnableAutoTextBoxDrawing
	ld hl, CopycatsHouse2FTrainerHeaders
	ld de, CopycatsHouse2F_ScriptPointers
	ld a, [wCopycatsHouse2FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCopycatsHouse2FCurScript], a
	ret

CopycatsHouse2F_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_COPYCATSHOUSE2F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_COPYCATSHOUSE2F_START_BATTLE
	dw_const CopycatsHouse2FEndBattleScript,         SCRIPT_COPYCATSHOUSE2F_END_BATTLE

CopycatsHouse2FEndBattleScript:
	call EndTrainerBattle
	call CopycatsHouse2FRestoreCopycatSprite
	xor a
	ld [wCopycatsHouse2FCurScript], a
	ld [wCurMapScript], a
	ret

CopycatsHouse2F_TextPointers:
	def_text_pointers
	dw_const CopycatsHouse2FCopycatText,      TEXT_COPYCATSHOUSE2F_COPYCAT
	dw_const CopycatsHouse2FDoduoText,        TEXT_COPYCATSHOUSE2F_DODUO
	dw_const CopycatsHouse2FRareDollText,     TEXT_COPYCATSHOUSE2F_MONSTER
	dw_const CopycatsHouse2FRareDollText,     TEXT_COPYCATSHOUSE2F_BIRD
	dw_const CopycatsHouse2FRareDollText,     TEXT_COPYCATSHOUSE2F_FAIRY
	dw_const CopycatsHouse2FSNESText,         TEXT_COPYCATSHOUSE2F_SNES
	dw_const CopycatsHouse2FPCText,           TEXT_COPYCATSHOUSE2F_PC

CopycatsHouse2FCopycatText:
	text_asm
	CheckEvent EVENT_BEAT_COPYCAT
	jp nz, .afterBattle
	CheckEvent EVENT_GOT_TM31
	jr nz, .gotItem
	ld a, TRUE
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .DoYouLikePokemonText
	call PrintText
	ld b, POKE_DOLL
	call IsItemInBag
	jr z, .done
	ld hl, .TM31PreReceiveText
	call PrintText
	lb bc, TM_MIMIC, 1
	call GiveItem
	jr nc, .bag_full
	ld hl, .ReceivedTM31Text
	call PrintText
	ld a, POKE_DOLL
	ldh [hItemToRemoveID], a
	farcall RemoveItemByID
	SetEvent EVENT_GOT_TM31
	jr .offerMirrorBattle
.bag_full
	ld hl, .TM31NoRoomText
	call PrintText
	jr .done
.gotItem
	ld hl, .TM31Explanation2Text
	call PrintText
.offerMirrorBattle
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .MirrorChallengeText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined
	ld hl, .MirrorTransformText
	call PrintText
	ld a, SFX_SHRINK
	call PlaySound
	call WaitForSoundToFinish
	call CopycatsHouse2FTransformCopycatSprite
	call CopycatsHouse2FStartMirrorBattle
	ld a, [wCurMapScript]
	ld [wCopycatsHouse2FCurScript], a
	jr .done
.declined
	ld hl, .MirrorDeclinedText
	call PrintText
	jr .done
.afterBattle
	ld hl, CopycatsHouse2FCopycatAfterBattleText
	call PrintText
	jp .offerMirrorBattle
.done
	jp TextScriptEnd

.DoYouLikePokemonText:
	text_far _CopycatsHouse2FCopycatDoYouLikePokemonText
	text_end

.TM31PreReceiveText:
	text_far _CopycatsHouse2FCopycatTM31PreReceiveText
	text_end

.ReceivedTM31Text:
	text_far _CopycatsHouse2FCopycatReceivedTM31Text
	sound_get_item_1
.TM31Explanation1Text:
	text_far _CopycatsHouse2FCopycatTM31Explanation1Text
	text_waitbutton
	text_end

.TM31Explanation2Text:
	text_far _CopycatsHouse2FCopycatTM31Explanation2Text
	text_end

.TM31NoRoomText:
	text_far _CopycatsHouse2FCopycatTM31NoRoomText
	text_waitbutton
	text_end

.MirrorChallengeText:
	text_far _CopycatsHouse2FMirrorChallengeText
	text_end

.MirrorDeclinedText:
	text_far _CopycatsHouse2FMirrorDeclinedText
	text_end

.MirrorTransformText:
	text_far _CopycatsHouse2FMirrorTransformText
	text_end

CopycatsHouse2FStartMirrorBattle:
	; Keep the first victory recorded even if a later rematch is lost.
	ld hl, CopycatsHouse2FTrainerHeader
	call StoreTrainerHeaderPointer
	xor a ; TRAINER_EVENT_FLAG_BIT
	call ReadTrainerHeaderInfo
	ld hl, CopycatsHouse2FCopycatBattleText
	call PrintText
	ld hl, CopycatsHouse2FCopycatEndBattleText
	ld de, CopycatsHouse2FCopycatEndBattleText
	call SaveEndBattleTextPointers
	ld a, COPYCATSHOUSE2F_COPYCAT
	ld [wSpriteIndex], a
	call EngageMapTrainer
	ld hl, wStatusFlags7
	set BIT_USE_CUR_MAP_SCRIPT, [hl]
	ld a, SCRIPT_COPYCATSHOUSE2F_START_BATTLE
	ld [wCurMapScript], a
	jp StartTrainerBattle

CopycatsHouse2FTransformCopycatSprite:
	ld a, SPRITE_RED
	jr CopycatsHouse2FSetCopycatSprite

CopycatsHouse2FRestoreCopycatSprite:
	ld a, SPRITE_BRUNETTE_GIRL

CopycatsHouse2FSetCopycatSprite:
	push af
	ld a, COPYCATSHOUSE2F_COPYCAT
	ldh [hSpriteIndex], a
	ld a, SPRITESTATEDATA1_PICTUREID
	ldh [hSpriteDataOffset], a
	call GetPointerWithinSpriteStateData1
	pop af
	ld [hl], a
	jp ReloadMapSpriteTilePatterns

CopycatsHouse2FTrainerHeaders:
	def_trainers
CopycatsHouse2FTrainerHeader:
	trainer EVENT_BEAT_COPYCAT, 0, CopycatsHouse2FCopycatBattleText, CopycatsHouse2FCopycatEndBattleText, CopycatsHouse2FCopycatAfterBattleText
	db -1 ; end

CopycatsHouse2FCopycatBattleText:
	text_far _CopycatsHouse2FCopycatBattleText
	text_end

CopycatsHouse2FCopycatEndBattleText:
	text_far _CopycatsHouse2FCopycatEndBattleText
	text_end

CopycatsHouse2FCopycatAfterBattleText:
	text_far _CopycatsHouse2FCopycatAfterBattleText
	text_end

CopycatsHouse2FDoduoText:
	text_far _CopycatsHouse2FDoduoText
	text_end

CopycatsHouse2FRareDollText:
	text_far _CopycatsHouse2FRareDollText
	text_end

CopycatsHouse2FSNESText:
	text_far _CopycatsHouse2FSNESText
	text_end

CopycatsHouse2FPCText:
	text_asm
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ld hl, .CantSeeText
	jr nz, .notUp
	ld hl, .MySecretsText
.notUp
	call PrintText
	jp TextScriptEnd

.MySecretsText:
	text_far _CopycatsHouse2FPCMySecretsText
	text_end

.CantSeeText:
	text_far _CopycatsHouse2FPCCantSeeText
	text_end
