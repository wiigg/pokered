LavenderTown_Script:
	call EnableAutoTextBoxDrawing
	ld hl, LavenderTown_ScriptPointers
	ld a, [wLavenderTownCurScript]
	jp CallFunctionInTable

LavenderTown_ScriptPointers:
	def_script_pointers
	dw_const LavenderTownDefaultScript,             SCRIPT_LAVENDERTOWN_DEFAULT
	dw_const LavenderTownWhiteHandPostBattleScript, SCRIPT_LAVENDERTOWN_WHITE_HAND_POST_BATTLE

LavenderTownDefaultScript:
	ret

LavenderTownWhiteHandPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jr z, LavenderTownResetScripts
	call UpdateSprites
	ld a, [wBattleWasEscaped]
	and a
	jr nz, LavenderTownResetScripts
	ld a, [wBattleResult]
	and a
	jr z, .defeated
	ld a, [wBattleWasCaptured]
	and a
	jr z, LavenderTownResetScripts
	SetEvent EVENT_BEAT_LAVENDER_WHITE_HAND
	ld hl, LavenderTownWhiteHandFollowedText
	call PrintText
	jr LavenderTownResetScripts
.defeated
	SetEvent EVENT_BEAT_LAVENDER_WHITE_HAND
	ld hl, LavenderTownWhiteHandFadedText
	call PrintText
	; fall through

LavenderTownResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wLavenderTownCurScript], a
	ld [wCurMapScript], a
	ret

LavenderTown_TextPointers:
	def_text_pointers
	dw_const LavenderTownLittleGirlText,       TEXT_LAVENDERTOWN_LITTLE_GIRL
	dw_const LavenderTownCooltrainerMText,     TEXT_LAVENDERTOWN_COOLTRAINER_M
	dw_const LavenderTownSuperNerdText,        TEXT_LAVENDERTOWN_SUPER_NERD
	dw_const LavenderTownSignText,             TEXT_LAVENDERTOWN_SIGN
	dw_const LavenderTownSilphScopeSignText,   TEXT_LAVENDERTOWN_SILPH_SCOPE_SIGN
	dw_const MartSignText,                     TEXT_LAVENDERTOWN_MART_SIGN
	dw_const PokeCenterSignText,               TEXT_LAVENDERTOWN_POKECENTER_SIGN
	dw_const LavenderTownPokemonHouseSignText, TEXT_LAVENDERTOWN_POKEMON_HOUSE_SIGN
	dw_const LavenderTownPokemonTowerSignText, TEXT_LAVENDERTOWN_POKEMON_TOWER_SIGN

LavenderTownLittleGirlText:
	text_asm
	CheckEvent EVENT_BEAT_LAVENDER_WHITE_HAND
	jr nz, .white_hand_gone
	ld hl, .DoYouBelieveInGhostsText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .does_not_believe
	ld hl, .SoThereAreBelieversText
	call PrintText
	jp TextScriptEnd
.does_not_believe
	ld hl, .HaHaGuessNotText
	call PrintText
	CheckEvent EVENT_RESCUED_MR_FUJI
	jp z, TextScriptEnd
	ld a, SFX_STOP_ALL_MUSIC
	ld [wNewSoundID], a
	call PlaySound
	ld c, 45
	call DelayFrames
	ld b, 2
	predef PredefShakeScreenHorizontally
	ld hl, .WhiteHandMovedText
	call PrintText
	ld a, HAUNTER
	call PlayCry
	call WaitForSoundToFinish
	ld a, HAUNTER
	ld [wCurOpponent], a
	ld a, 35
	ld [wCurEnemyLevel], a
	ld a, SCRIPT_LAVENDERTOWN_WHITE_HAND_POST_BATTLE
	ld [wLavenderTownCurScript], a
	ld [wCurMapScript], a
	jp TextScriptEnd
.white_hand_gone
	ld hl, .ShoulderFeelsLighterText
	call PrintText
	jp TextScriptEnd

.DoYouBelieveInGhostsText:
	text_far _LavenderTownLittleGirlDoYouBelieveInGhostsText
	text_end

.SoThereAreBelieversText:
	text_far _LavenderTownLittleGirlSoThereAreBelieversText
	text_end

.HaHaGuessNotText:
	text_far _LavenderTownLittleGirlHaHaGuessNotText
	text_end

.WhiteHandMovedText:
	text_far _LavenderTownLittleGirlWhiteHandMovedText
	text_end

.ShoulderFeelsLighterText:
	text_far _LavenderTownLittleGirlShoulderFeelsLighterText
	text_end

LavenderTownWhiteHandFadedText:
	text_far _LavenderTownWhiteHandFadedText
	text_end

LavenderTownWhiteHandFollowedText:
	text_far _LavenderTownWhiteHandFollowedText
	text_end

LavenderTownCooltrainerMText:
	text_far _LavenderTownCooltrainerMText
	text_end

LavenderTownSuperNerdText:
	text_far _LavenderTownSuperNerdText
	text_end

LavenderTownSignText:
	text_far _LavenderTownSignText
	text_end

LavenderTownSilphScopeSignText:
	text_far _LavenderTownSilphScopeSignText
	text_end

LavenderTownPokemonHouseSignText:
	text_far _LavenderTownPokemonHouseSignText
	text_end

LavenderTownPokemonTowerSignText:
	text_far _LavenderTownPokemonTowerSignText
	text_end
