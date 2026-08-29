FuchsiaCity_Script:
	call FuchsiaCityLoadRhyhornEscapeObjects
	call EnableAutoTextBoxDrawing
	ld hl, FuchsiaCity_ScriptPointers
	ld a, [wFuchsiaCityCurScript]
	jp CallFunctionInTable

FuchsiaCityLoadRhyhornEscapeObjects:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_FUCHSIA_RHYHORN_ESCAPED
	jr z, .hide
	CheckEvent EVENT_BEAT_FUCHSIA_ESCAPED_RHYHORN
	jr nz, .hide
	CheckEvent EVENT_SAW_FUCHSIA_RHYHORN_ESCAPE
	jr z, .hide
	ld a, [wXCoord]
	cp 18
	jr nz, .show
	ld a, [wYCoord]
	cp 8
	jr z, .hide
	cp 10
	jr z, .hide
.show
	ld a, TOGGLE_FUCHSIA_CITY_ESCAPED_RHYHORN
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, TOGGLE_FUCHSIA_CITY_CHASING_WARDEN
	ld [wToggleableObjectIndex], a
	predef_jump ShowObject
.hide
	ld a, TOGGLE_FUCHSIA_CITY_ESCAPED_RHYHORN
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, TOGGLE_FUCHSIA_CITY_CHASING_WARDEN
	ld [wToggleableObjectIndex], a
	predef_jump HideObject

FuchsiaCity_ScriptPointers:
	def_script_pointers
	dw_const FuchsiaCityDefaultScript, SCRIPT_FUCHSIACITY_DEFAULT
	dw_const FuchsiaCityRhyhornMovingScript, SCRIPT_FUCHSIACITY_RHYHORN_MOVING
	dw_const FuchsiaCityWardenMovingScript, SCRIPT_FUCHSIACITY_WARDEN_MOVING
	dw_const FuchsiaCityRhyhornPostBattleScript, SCRIPT_FUCHSIACITY_RHYHORN_POST_BATTLE

FuchsiaCityDefaultScript:
	CheckEvent EVENT_FUCHSIA_RHYHORN_ESCAPED
	ret z
	CheckEvent EVENT_SAW_FUCHSIA_RHYHORN_ESCAPE
	ret nz
	ld a, [wXCoord]
	cp 18
	ret nz
	ld a, [wYCoord]
	cp 4
	ret nz
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TOGGLE_FUCHSIA_CITY_ESCAPED_RHYHORN
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ld a, TOGGLE_FUCHSIA_CITY_CHASING_WARDEN
	ld [wToggleableObjectIndex], a
	predef ShowObject

	ld a, FUCHSIACITY_ESCAPED_RHYHORN
	ld [wSpriteIndex], a
	call GetSpritePosition1
	ldh a, [hSpriteScreenYCoord]
	sub 4 * 2 * TILE_HEIGHT
	ldh [hSpriteScreenYCoord], a
	ldh a, [hSpriteMapYCoord]
	sub 4
	ldh [hSpriteMapYCoord], a
	call SetSpritePosition1

	ld a, FUCHSIACITY_CHASING_WARDEN
	ld [wSpriteIndex], a
	call GetSpritePosition1
	ldh a, [hSpriteScreenYCoord]
	sub 3 * 2 * TILE_HEIGHT
	ldh [hSpriteScreenYCoord], a
	ldh a, [hSpriteMapYCoord]
	sub 3
	ldh [hSpriteMapYCoord], a
	call SetSpritePosition1
	call UpdateSprites

	ld hl, FuchsiaCityRhyhornEscapeIntroText
	call PrintText
	ld a, RHYHORN
	call PlayCry
	call WaitForSoundToFinish
	ld b, 2
	predef PredefShakeScreenHorizontally
	ld a, FUCHSIACITY_ESCAPED_RHYHORN
	ldh [hSpriteIndex], a
	ld de, FuchsiaCityRhyhornMovement
	call MoveSprite
	ld a, SCRIPT_FUCHSIACITY_RHYHORN_MOVING
	ld [wFuchsiaCityCurScript], a
	ret

FuchsiaCityRhyhornMovement:
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db -1 ; end

FuchsiaCityRhyhornMovingScript:
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	ret nz
	ld a, FUCHSIACITY_CHASING_WARDEN
	ldh [hSpriteIndex], a
	ld de, FuchsiaCityWardenMovement
	call MoveSprite
	ld a, SCRIPT_FUCHSIACITY_WARDEN_MOVING
	ld [wFuchsiaCityCurScript], a
	ret

FuchsiaCityWardenMovement:
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db -1 ; end

FuchsiaCityWardenMovingScript:
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	ret nz
	SetEvent EVENT_SAW_FUCHSIA_RHYHORN_ESCAPE
	xor a
	ld [wJoyIgnore], a
	ld [wFuchsiaCityCurScript], a
	ret

FuchsiaCityRhyhornPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jr z, FuchsiaCityResetScripts
	ld a, [wBattleWasEscaped]
	and a
	jr nz, FuchsiaCityResetScripts
	ld a, [wBattleResult]
	and a
	jr z, .resolved
	ld a, [wBattleWasCaptured]
	and a
	jr z, FuchsiaCityResetScripts
.resolved
	SetEvent EVENT_BEAT_FUCHSIA_ESCAPED_RHYHORN
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TOGGLE_FUCHSIA_CITY_ESCAPED_RHYHORN
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld hl, FuchsiaCityWardenThanksText
	call PrintText
	ld a, TOGGLE_FUCHSIA_CITY_CHASING_WARDEN
	ld [wToggleableObjectIndex], a
	predef HideObject
	call UpdateSprites
	; fall through

FuchsiaCityResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wFuchsiaCityCurScript], a
	ld [wCurMapScript], a
	ret

FuchsiaCity_TextPointers:
	def_text_pointers
	dw_const FuchsiaCityYoungster1Text,      TEXT_FUCHSIACITY_YOUNGSTER1
	dw_const FuchsiaCityGamblerText,         TEXT_FUCHSIACITY_GAMBLER
	dw_const FuchsiaCityErikText,            TEXT_FUCHSIACITY_ERIK
	dw_const FuchsiaCityYoungster2Text,      TEXT_FUCHSIACITY_YOUNGSTER2
	dw_const FuchsiaCityPokemonText,         TEXT_FUCHSIACITY_CHANSEY
	dw_const FuchsiaCityPokemonText,         TEXT_FUCHSIACITY_VOLTORB
	dw_const FuchsiaCityPokemonText,         TEXT_FUCHSIACITY_KANGASKHAN
	dw_const FuchsiaCityPokemonText,         TEXT_FUCHSIACITY_SLOWPOKE
	dw_const FuchsiaCityPokemonText,         TEXT_FUCHSIACITY_LAPRAS
	dw_const FuchsiaCityPokemonText,         TEXT_FUCHSIACITY_FOSSIL
	dw_const FuchsiaCitySaraText,            TEXT_FUCHSIACITY_SARA
	dw_const FuchsiaCityEscapedRhyhornText,  TEXT_FUCHSIACITY_ESCAPED_RHYHORN
	dw_const FuchsiaCityChasingWardenText,   TEXT_FUCHSIACITY_CHASING_WARDEN
	dw_const FuchsiaCitySignText,            TEXT_FUCHSIACITY_SIGN1
	dw_const FuchsiaCitySignText,            TEXT_FUCHSIACITY_SIGN2
	dw_const FuchsiaCitySafariGameSignText,  TEXT_FUCHSIACITY_SAFARI_GAME_SIGN
	dw_const MartSignText,                   TEXT_FUCHSIACITY_MART_SIGN
	dw_const PokeCenterSignText,             TEXT_FUCHSIACITY_POKECENTER_SIGN
	dw_const FuchsiaCityWardensHomeSignText, TEXT_FUCHSIACITY_WARDENS_HOME_SIGN
	dw_const FuchsiaCitySafariZoneSignText,  TEXT_FUCHSIACITY_SAFARI_ZONE_SIGN
	dw_const FuchsiaCityGymSignText,         TEXT_FUCHSIACITY_GYM_SIGN
	dw_const FuchsiaCityChanseySignText,     TEXT_FUCHSIACITY_CHANSEY_SIGN
	dw_const FuchsiaCityVoltorbSignText,     TEXT_FUCHSIACITY_VOLTORB_SIGN
	dw_const FuchsiaCityKangaskhanSignText,  TEXT_FUCHSIACITY_KANGASKHAN_SIGN
	dw_const FuchsiaCitySlowpokeSignText,    TEXT_FUCHSIACITY_SLOWPOKE_SIGN
	dw_const FuchsiaCityLaprasSignText,      TEXT_FUCHSIACITY_LAPRAS_SIGN
	dw_const FuchsiaCityFossilSignText,      TEXT_FUCHSIACITY_FOSSIL_SIGN

FuchsiaCityYoungster1Text:
	text_far _FuchsiaCityYoungster1Text
	text_end

FuchsiaCityGamblerText:
	text_far _FuchsiaCityGamblerText
	text_end

FuchsiaCityErikText:
	text_asm
	CheckEvent EVENT_REUNITED_ERIK_AND_SARA
	jr nz, .reunited
	CheckEvent EVENT_ERIK_ASKED_TO_FIND_SARA
	jr nz, .waiting
	ld hl, .LookingForSaraText
	call PrintText
	SetEvent EVENT_ERIK_ASKED_TO_FIND_SARA
	jr .done
.waiting
	ld hl, .WaitingForSaraText
	call PrintText
	jr .done
.reunited
	ld hl, .ReunitedText
	call PrintText
.done
	jp TextScriptEnd

.LookingForSaraText:
	text_far _FuchsiaCityErikLookingForSaraText
	text_end

.WaitingForSaraText:
	text_far _FuchsiaCityErikWaitingForSaraText
	text_end

.ReunitedText:
	text_far _FuchsiaCityErikReunitedText
	text_end

FuchsiaCityYoungster2Text:
	text_far _FuchsiaCityYoungster2Text
	text_end

FuchsiaCityPokemonText:
	text_far _FuchsiaCityPokemonText
	text_end

FuchsiaCitySaraText:
	text_far _FuchsiaCitySaraText
	text_end

FuchsiaCityEscapedRhyhornText:
	text_asm
	ld hl, .TurnsText
	call PrintText
	ld a, RHYHORN
	call PlayCry
	call WaitForSoundToFinish
	ld b, 2
	predef PredefShakeScreenHorizontally
	xor a ; BATTLE_TYPE_NORMAL
	ld [wBattleType], a
	ld a, RHYHORN
	ld [wCurOpponent], a
	ld a, 35
	ld [wCurEnemyLevel], a
	ld a, SCRIPT_FUCHSIACITY_RHYHORN_POST_BATTLE
	ld [wFuchsiaCityCurScript], a
	ld [wCurMapScript], a
	xor a
	ld [wJoyIgnore], a
	jp TextScriptEnd

.TurnsText:
	text_far _FuchsiaCityEscapedRhyhornTurnsText
	text_end

FuchsiaCityChasingWardenText:
	text_far _FuchsiaCityChasingWardenText
	text_end

FuchsiaCityRhyhornEscapeIntroText:
	text_far _FuchsiaCityRhyhornEscapeIntroText
	text_end

FuchsiaCityWardenThanksText:
	text_far _FuchsiaCityWardenThanksText
	text_end

FuchsiaCitySignText:
	text_far _FuchsiaCitySignText
	text_end

FuchsiaCitySafariGameSignText:
	text_far _FuchsiaCitySafariGameSignText
	text_end

FuchsiaCityWardensHomeSignText:
	text_far _FuchsiaCityWardensHomeSignText
	text_end

FuchsiaCitySafariZoneSignText:
	text_far _FuchsiaCitySafariZoneSignText
	text_end

FuchsiaCityGymSignText:
	text_far _FuchsiaCityGymSignText
	text_end

FuchsiaCityChanseySignText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, CHANSEY
	call DisplayPokedex
	jp TextScriptEnd

.Text:
	text_far _FuchsiaCityChanseySignText
	text_end

FuchsiaCityVoltorbSignText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, VOLTORB
	call DisplayPokedex
	jp TextScriptEnd

.Text:
	text_far _FuchsiaCityVoltorbSignText
	text_end

FuchsiaCityKangaskhanSignText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, KANGASKHAN
	call DisplayPokedex
	jp TextScriptEnd

.Text:
	text_far _FuchsiaCityKangaskhanSignText
	text_end

FuchsiaCitySlowpokeSignText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, SLOWPOKE
	call DisplayPokedex
	jp TextScriptEnd

.Text:
	text_far _FuchsiaCitySlowpokeSignText
	text_end

FuchsiaCityLaprasSignText:
	text_asm
	ld hl, .Text
	call PrintText
	ld a, LAPRAS
	call DisplayPokedex
	jp TextScriptEnd

.Text:
	text_far _FuchsiaCityLaprasSignText
	text_end

FuchsiaCityFossilSignText:
	text_asm
	CheckEvent EVENT_GOT_DOME_FOSSIL
	jr nz, .got_dome_fossil
	CheckEventReuseA EVENT_GOT_HELIX_FOSSIL
	jr nz, .got_helix_fossil
	ld hl, .UndeterminedText
	call PrintText
	jr .done
.got_dome_fossil
	ld hl, .OmanyteText
	call PrintText
	ld a, OMANYTE
	jr .display
.got_helix_fossil
	ld hl, .KabutoText
	call PrintText
	ld a, KABUTO
.display
	call DisplayPokedex
.done
	jp TextScriptEnd

.OmanyteText:
	text_far _FuchsiaCityFossilSignOmanyteText
	text_end

.KabutoText:
	text_far _FuchsiaCityFossilSignKabutoText
	text_end

.UndeterminedText:
	text_far _FuchsiaCityFossilSignUndeterminedText
	text_end
