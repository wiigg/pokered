CeladonChiefHouse_Script:
	call EnableAutoTextBoxDrawing
	ld hl, CeladonChiefHouseTrainerHeaders
	ld de, CeladonChiefHouse_ScriptPointers
	ld a, [wCeladonChiefHouseCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCeladonChiefHouseCurScript], a
	ret

CeladonChiefHouse_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,                       SCRIPT_CELADONCHIEFHOUSE_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle,          SCRIPT_CELADONCHIEFHOUSE_START_BATTLE
	dw_const CeladonChiefHouseChiefPostBattleScript,         SCRIPT_CELADONCHIEFHOUSE_CHIEF_POST_BATTLE

CeladonChiefHouseChiefPostBattleScript:
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jr z, CeladonChiefHouseResetScripts
	ld a, TEXT_CELADONCHIEFHOUSE_CHIEF
	ldh [hTextID], a
	call DisplayTextID
	; fall through

CeladonChiefHouseResetScripts:
	xor a ; SCRIPT_CELADONCHIEFHOUSE_DEFAULT
	ld [wJoyIgnore], a
	ld [wCeladonChiefHouseCurScript], a
	ld [wCurMapScript], a
	ret

CeladonChiefHouse_TextPointers:
	def_text_pointers
	dw_const CeladonChiefHouseChiefText,  TEXT_CELADONCHIEFHOUSE_CHIEF
	dw_const CeladonChiefHouseRocketText, TEXT_CELADONCHIEFHOUSE_ROCKET
	dw_const CeladonChiefHouseSailorText, TEXT_CELADONCHIEFHOUSE_SAILOR

CeladonChiefHouseChiefText:
	text_asm
	CheckEvent EVENT_BEAT_CELADON_CHIEF
	jr nz, .caseClosed
	CheckEvent EVENT_FOUND_CELADON_LEDGER
	jr nz, .confront
	ld hl, .OriginalText
	jr .print
.confront
	ld hl, .ConfrontationText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined
	ld hl, CeladonChiefHouseTrainerHeader
	call TalkToTrainer
	jp TextScriptEnd
.declined
	ld hl, .DeclinedText
	jr .print
.caseClosed
	ld hl, CeladonChiefHouseChiefAfterBattleText
.print
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _CeladonChiefHouseChiefText
	text_end

.ConfrontationText:
	text_far _CeladonChiefHouseChiefConfrontationText
	text_end

.DeclinedText:
	text_far _CeladonChiefHouseChiefDeclinedText
	text_end

CeladonChiefHouseRocketText:
	text_asm
	CheckEvent EVENT_BEAT_CELADON_CHIEF
	jr nz, .caseClosed
	CheckEvent EVENT_FOUND_CELADON_LEDGER
	ld hl, .OriginalText
	jr z, .print
	ld hl, .NervousText
	jr .print
.caseClosed
	ld hl, .AfterBattleText
.print
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _CeladonChiefHouseRocketText
	text_end

.NervousText:
	text_far _CeladonChiefHouseRocketNervousText
	text_end

.AfterBattleText:
	text_far _CeladonChiefHouseRocketAfterBattleText
	text_end

CeladonChiefHouseSailorText:
	text_far _CeladonChiefHouseSailorText
	text_end

CeladonChiefHouseTrainerHeaders:
	def_trainers
CeladonChiefHouseTrainerHeader:
	trainer EVENT_BEAT_CELADON_CHIEF, 0, CeladonChiefHouseChiefBattleText, CeladonChiefHouseChiefEndBattleText, CeladonChiefHouseChiefAfterBattleText
	db -1 ; end

CeladonChiefHouseChiefBattleText:
	text_far _CeladonChiefHouseChiefBattleText
	text_end

CeladonChiefHouseChiefEndBattleText:
	text_far _CeladonChiefHouseChiefEndBattleText
	text_end

CeladonChiefHouseChiefAfterBattleText:
	text_far _CeladonChiefHouseChiefAfterBattleText
	text_end
