MtMoonPokecenter_Script:
	call Serial_TryEstablishingExternallyClockedConnection
	call EnableAutoTextBoxDrawing
	ld hl, MtMoonPokecenterTrainerHeaders
	ld de, MtMoonPokecenter_ScriptPointers
	ld a, [wMtMoonPokecenterCurScript]
	call ExecuteCurMapScriptInTable
	ld [wMtMoonPokecenterCurScript], a
	ret

MtMoonPokecenter_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,                              SCRIPT_MTMOONPOKECENTER_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle,                 SCRIPT_MTMOONPOKECENTER_START_BATTLE
	dw_const MtMoonPokecenterMagikarpSalesmanPostBattleScript,      SCRIPT_MTMOONPOKECENTER_MAGIKARP_SALESMAN_POST_BATTLE

MtMoonPokecenterMagikarpSalesmanPostBattleScript:
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jr z, MtMoonPokecenterResetScripts
	ld a, TEXT_MTMOONPOKECENTER_MAGIKARP_SALESMAN_REWARD
	ldh [hTextID], a
	call DisplayTextID
	; fall through

MtMoonPokecenterResetScripts:
	xor a ; SCRIPT_MTMOONPOKECENTER_DEFAULT
	ld [wJoyIgnore], a
	ld [wMtMoonPokecenterCurScript], a
	ld [wCurMapScript], a
	ret

MtMoonPokecenter_TextPointers:
	def_text_pointers
	dw_const MtMoonPokecenterNurseText,            TEXT_MTMOONPOKECENTER_NURSE
	dw_const MtMoonPokecenterYoungsterText,        TEXT_MTMOONPOKECENTER_YOUNGSTER
	dw_const MtMoonPokecenterGentlemanText,        TEXT_MTMOONPOKECENTER_GENTLEMAN
	dw_const MtMoonPokecenterMagikarpSalesmanText, TEXT_MTMOONPOKECENTER_MAGIKARP_SALESMAN
	dw_const MtMoonPokecenterClipboardText,        TEXT_MTMOONPOKECENTER_CLIPBOARD
	dw_const MtMoonPokecenterLinkReceptionistText, TEXT_MTMOONPOKECENTER_LINK_RECEPTIONIST
	dw_const MtMoonPokecenterWandererText,        TEXT_MTMOONPOKECENTER_WANDERER
	dw_const MtMoonPokecenterMagikarpSalesmanRewardText, TEXT_MTMOONPOKECENTER_MAGIKARP_SALESMAN_REWARD

MtMoonPokecenterNurseText:
	script_pokecenter_nurse

MtMoonPokecenterYoungsterText:
	text_far _MtMoonPokecenterYoungsterText
	text_end

MtMoonPokecenterGentlemanText:
	text_far _MtMoonPokecenterGentlemanText
	text_end

MtMoonPokecenterMagikarpSalesmanText:
	text_asm
	CheckEvent EVENT_BOUGHT_MAGIKARP, 1
	jp c, .alreadyBoughtMagikarp
	ld hl, .IGotADealText
	call PrintText
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .choseNo
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $5
	ldh [hMoney + 1], a
	call HasEnoughMoney
	jr nc, .enoughMoney
	ld hl, .NoMoneyText
	jr .printText
.enoughMoney
	lb bc, MAGIKARP, 5
	call GivePokemon
	jr nc, .done
	xor a
	ld [wPriceTemp], a
	ld [wPriceTemp + 2], a
	ld a, $5
	ld [wPriceTemp + 1], a
	ld hl, wPriceTemp + 2
	ld de, wPlayerMoney + 2
	ld c, $3
	predef SubBCDPredef
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	SetEvent EVENT_BOUGHT_MAGIKARP
	jr .done
.choseNo
	ld hl, .NoText
	jr .printText
.alreadyBoughtMagikarp
	CheckEvent EVENT_BEAT_MAGIKARP_SALESMAN
	jr nz, .wonChallenge
	call MtMoonPokecenterPlayerOwnsGyarados
	jr z, .noRefunds
	ld hl, .ChallengeText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declinedChallenge
	ld hl, MtMoonPokecenterMagikarpSalesmanTrainerHeader
	call TalkToTrainer
	jp TextScriptEnd
.declinedChallenge
	ld hl, .DeclinedChallengeText
	jr .printText
.noRefunds
	ld hl, .NoRefundsText
	jr .printText
.wonChallenge
	ld hl, .AfterChallengeText
.printText
	call PrintText
.done
	jp TextScriptEnd

.IGotADealText
	text_far _MtMoonPokecenterMagikarpSalesmanIGotADealText
	text_end

.NoText
	text_far _MtMoonPokecenterMagikarpSalesmanNoText
	text_end

.NoMoneyText
	text_far _MtMoonPokecenterMagikarpSalesmanNoMoneyText
	text_end

.NoRefundsText
	text_far _MtMoonPokecenterMagikarpSalesmanNoRefundsText
	text_end

.ChallengeText
	text_far _MtMoonPokecenterMagikarpSalesmanChallengeText
	text_end

.DeclinedChallengeText
	text_far _MtMoonPokecenterMagikarpSalesmanDeclinedChallengeText
	text_end

.AfterChallengeText
	text_far _MtMoonPokecenterMagikarpSalesmanAfterChallengeText
	text_end

MtMoonPokecenterPlayerOwnsGyarados:
	ld hl, wPokedexOwned
	ld b, FLAG_TEST
	ld c, DEX_GYARADOS - 1
	predef FlagActionPredef
	ld a, c
	and a
	ret

MtMoonPokecenterClipboardText:
	text_far _MtMoonPokecenterClipboardText
	text_end

MtMoonPokecenterLinkReceptionistText:
	script_cable_club_receptionist

MtMoonPokecenterWandererText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, SFX_TELEPORT_ENTER_1
	call PlaySound
	call GBFadeOutToWhite
	SetEvent EVENT_MET_WANDERER_MT_MOON
	ld a, TOGGLE_MT_MOON_POKECENTER_WANDERER
	ld [wToggleableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromWhite
	call WaitForSoundToFinish
	jp TextScriptEnd

.Text:
	text_far _MtMoonPokecenterWandererText
	text_end

MtMoonPokecenterMagikarpSalesmanRewardText:
	text_asm
	ld hl, .DividendText
	call PrintText
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, $5
	ldh [hMoney + 1], a
	ld hl, hMoney + 2
	ld de, wPlayerMoney + 2
	ld c, 3
	predef AddBCDPredef
	ld a, SFX_PURCHASE
	call PlaySoundWaitForCurrent
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	jp TextScriptEnd

.DividendText:
	text_far _MtMoonPokecenterMagikarpSalesmanDividendText
	text_end

MtMoonPokecenterTrainerHeaders:
	def_trainers 4
MtMoonPokecenterMagikarpSalesmanTrainerHeader:
	trainer EVENT_BEAT_MAGIKARP_SALESMAN, 0, MtMoonPokecenterMagikarpSalesmanBattleText, MtMoonPokecenterMagikarpSalesmanEndBattleText, MtMoonPokecenterMagikarpSalesmanAfterChallengeText
	db -1 ; end

MtMoonPokecenterMagikarpSalesmanBattleText:
	text_far _MtMoonPokecenterMagikarpSalesmanBattleText
	text_end

MtMoonPokecenterMagikarpSalesmanEndBattleText:
	text_far _MtMoonPokecenterMagikarpSalesmanEndBattleText
	text_end

MtMoonPokecenterMagikarpSalesmanAfterChallengeText:
	text_far _MtMoonPokecenterMagikarpSalesmanAfterChallengeText
	text_end
