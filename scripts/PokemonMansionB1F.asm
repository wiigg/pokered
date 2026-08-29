PokemonMansionB1F_Script:
	call MansionB1FCheckReplaceSwitchDoorBlocks
	call EnableAutoTextBoxDrawing
	ld hl, Mansion4TrainerHeaders
	ld de, PokemonMansionB1F_ScriptPointers
	ld a, [wPokemonMansionB1FCurScript]
	call ExecuteCurMapScriptInTable
	ld [wPokemonMansionB1FCurScript], a
	ret

MansionB1FCheckReplaceSwitchDoorBlocks:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_MANSION_SWITCH_ON
	jr nz, .switchTurnedOn
	ld a, $e
	lb bc, 8, 13
	call Mansion2ReplaceBlock
	ld a, $e
	lb bc, 11, 6
	call Mansion2ReplaceBlock
	ld a, $5f
	lb bc, 3, 4
	call Mansion2ReplaceBlock
	ld a, $54
	lb bc, 8, 8
	call Mansion2ReplaceBlock
	jr .checkDittoStatue
.switchTurnedOn
	ld a, $2d
	lb bc, 8, 13
	call Mansion2ReplaceBlock
	ld a, $5f
	lb bc, 11, 6
	call Mansion2ReplaceBlock
	ld a, $e
	lb bc, 3, 4
	call Mansion2ReplaceBlock
	ld a, $e
	lb bc, 8, 8
	call Mansion2ReplaceBlock
	; fall through
.checkDittoStatue
	CheckEvent EVENT_BEAT_MANSION_DITTO
	ret z
	jp PokemonMansionB1FHideDittoStatue

PokemonMansionB1FHideDittoStatue:
	ld a, $e
	jr PokemonMansionB1FReplaceDittoStatueBlock

PokemonMansionB1FShowDittoStatue:
	ld a, $77

PokemonMansionB1FReplaceDittoStatueBlock:
	ld [wNewTileBlockID], a
	lb bc, 12, 9
	predef_jump ReplaceTileBlock

Mansion4Script_Switches::
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	xor a
	ldh [hJoyHeld], a
	ld a, TEXT_POKEMONMANSIONB1F_SWITCH
	ldh [hTextID], a
	jp DisplayTextID

Mansion4DittoStatueScript::
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	xor a
	ldh [hJoyHeld], a
	CheckEvent EVENT_BEAT_MANSION_DITTO
	ld a, TEXT_POKEMONMANSIONB1F_DITTO_STATUE
	jr z, .displayText
	ld a, TEXT_POKEMONMANSIONB1F_BARE_SWITCH
.displayText
	ldh [hTextID], a
	jp DisplayTextID

PokemonMansionB1F_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_POKEMONMANSIONB1F_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_POKEMONMANSIONB1F_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_POKEMONMANSIONB1F_END_BATTLE
	dw_const PokemonMansionB1FDittoPostBattleScript, SCRIPT_POKEMONMANSIONB1F_DITTO_POST_BATTLE

PokemonMansionB1FDittoPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jr z, .restoreSilently
	ld a, [wBattleWasEscaped]
	and a
	jr nz, .reformed
	ld a, [wBattleResult]
	and a
	jr z, .finished
	ld a, [wBattleWasCaptured]
	and a
	jr z, .reformed
.finished
	SetEvent EVENT_BEAT_MANSION_DITTO
	call PokemonMansionB1FHideDittoStatue
	ld hl, PokemonMansionB1FDittoGoneText
	call PrintText
	jr PokemonMansionB1FResetScripts
.reformed
	call PokemonMansionB1FShowDittoStatue
	ld hl, PokemonMansionB1FDittoReformedText
	call PrintText
	jr PokemonMansionB1FResetScripts
.restoreSilently
	call PokemonMansionB1FShowDittoStatue
	; fall through

PokemonMansionB1FResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wPokemonMansionB1FCurScript], a
	ld [wCurMapScript], a
	ret

PokemonMansionB1F_TextPointers:
	def_text_pointers
	dw_const PokemonMansionB1FBurglarText,   TEXT_POKEMONMANSIONB1F_BURGLAR
	dw_const PokemonMansionB1FScientistText, TEXT_POKEMONMANSIONB1F_SCIENTIST
	dw_const PickUpItemText,                 TEXT_POKEMONMANSIONB1F_RARE_CANDY
	dw_const PickUpItemText,                 TEXT_POKEMONMANSIONB1F_FULL_RESTORE
	dw_const PickUpItemText,                 TEXT_POKEMONMANSIONB1F_TM_BLIZZARD
	dw_const PickUpItemText,                 TEXT_POKEMONMANSIONB1F_TM_SOLARBEAM
	dw_const PokemonMansionB1FDiaryText,     TEXT_POKEMONMANSIONB1F_DIARY
	dw_const PickUpItemText,                 TEXT_POKEMONMANSIONB1F_SECRET_KEY
	dw_const PokemonMansionB1FWandererText,  TEXT_POKEMONMANSIONB1F_WANDERER
	dw_const PokemonMansion2FSwitchText,     TEXT_POKEMONMANSIONB1F_SWITCH ; This switch uses the text script from the 2F.
	dw_const PokemonMansionB1FDittoStatueText, TEXT_POKEMONMANSIONB1F_DITTO_STATUE
	dw_const PokemonMansionB1FBareSwitchText,  TEXT_POKEMONMANSIONB1F_BARE_SWITCH

Mansion4TrainerHeaders:
	def_trainers
Mansion4TrainerHeader0:
	trainer EVENT_BEAT_MANSION_4_TRAINER_0, 0, PokemonMansionB1FBurglarBattleText, PokemonMansionB1FBurglarEndBattleText, PokemonMansionB1FBurglarAfterBattleText
Mansion4TrainerHeader1:
	trainer EVENT_BEAT_MANSION_4_TRAINER_1, 3, PokemonMansionB1FScientistBattleText, PokemonMansionB1FScientistEndBattleText, PokemonMansionB1FScientistAfterBattleText
	db -1 ; end

PokemonMansionB1FBurglarText:
	text_asm
	ld hl, Mansion4TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

PokemonMansionB1FScientistText:
	text_asm
	ld hl, Mansion4TrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

PokemonMansionB1FBurglarBattleText:
	text_far _PokemonMansionB1FBurglarBattleText
	text_end

PokemonMansionB1FBurglarEndBattleText:
	text_far _PokemonMansionB1FBurglarEndBattleText
	text_end

PokemonMansionB1FBurglarAfterBattleText:
	text_far _PokemonMansionB1FBurglarAfterBattleText
	text_end

PokemonMansionB1FScientistBattleText:
	text_far _PokemonMansionB1FScientistBattleText
	text_end

PokemonMansionB1FScientistEndBattleText:
	text_far _PokemonMansionB1FScientistEndBattleText
	text_end

PokemonMansionB1FScientistAfterBattleText:
	text_far _PokemonMansionB1FScientistAfterBattleText
	text_end

PokemonMansionB1FDiaryText:
	text_far _PokemonMansionB1FDiaryText
	text_end

PokemonMansionB1FDittoStatueText:
	text_asm
	ld hl, PokemonMansionB1FSwitchQuestionText
	call PokemonMansionB1FAskToPressSwitch
	jr nz, .notPressed
	call PokemonMansionB1FPressSwitch
	call WaitForSoundToFinish
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, .DistortsText
	call PrintText
	ld a, SFX_SHRINK
	call PlaySound
	ld b, $2
	predef ChangeBGPalColor0_4Frames
	ld b, 2
	predef PredefShakeScreenHorizontally
	call WaitForSoundToFinish
	call PokemonMansionB1FHideDittoStatue
	ld a, DITTO
	call PlayCry
	ld a, DITTO
	ld [wCurOpponent], a
	ld a, 42
	ld [wCurEnemyLevel], a
	ld a, SCRIPT_POKEMONMANSIONB1F_DITTO_POST_BATTLE
	ld [wPokemonMansionB1FCurScript], a
	ld [wCurMapScript], a
	jp TextScriptEnd
.notPressed
	ld hl, PokemonMansionB1FSwitchNotPressedText
	call PrintText
	jp TextScriptEnd

.DistortsText:
	text_far _PokemonMansionB1FDittoStatueDistortsText
	text_end

PokemonMansionB1FBareSwitchText:
	text_asm
	ld hl, .Text
	call PokemonMansionB1FAskToPressSwitch
	jr nz, .notPressed
	call PokemonMansionB1FPressSwitch
	jp TextScriptEnd
.notPressed
	ld hl, PokemonMansionB1FSwitchNotPressedText
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _PokemonMansionB1FBareSwitchText
	text_end

PokemonMansionB1FAskToPressSwitch:
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ret

PokemonMansionB1FPressSwitch:
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, wCurrentMapScriptFlags
	set BIT_CUR_MAP_LOADED_1, [hl]
	ld hl, PokemonMansionB1FSwitchPressedText
	call PrintText
	ld a, SFX_GO_INSIDE
	call PlaySound
	CheckAndSetEvent EVENT_MANSION_SWITCH_ON
	ret z
	ResetEventReuseHL EVENT_MANSION_SWITCH_ON
	ret

PokemonMansionB1FSwitchQuestionText:
	text_far _PokemonMansion2FSwitchText
	text_end

PokemonMansionB1FSwitchPressedText:
	text_far _PokemonMansion2FSwitchPressedText
	text_end

PokemonMansionB1FSwitchNotPressedText:
	text_far _PokemonMansion2FSwitchNotPressedText
	text_end

PokemonMansionB1FDittoReformedText:
	text_far _PokemonMansionB1FDittoReformedText
	text_end

PokemonMansionB1FDittoGoneText:
	text_far _PokemonMansionB1FDittoGoneText
	text_end

PokemonMansionB1FWandererText:
	text_asm
	ld hl, .Text
	call PrintText
	SetEvent EVENT_MET_WANDERER_POKEMON_MANSION
	ld a, TOGGLE_POKEMON_MANSION_B1F_WANDERER
	ld [wToggleableObjectIndex], a
	predef HideObject
	jp TextScriptEnd

.Text:
	text_far _WandererMansionText
	text_end
