Route6Gate_Script:
	call EnableAutoTextBoxDrawing
	ld hl, Route6Gate_ScriptPointers
	ld a, [wRoute6GateCurScript]
	call CallFunctionInTable
	ret

Route6Gate_ScriptPointers:
	def_script_pointers
	dw_const Route6GateDefaultScript,      SCRIPT_ROUTE6GATE_DEFAULT
	dw_const Route6GatePlayerMovingScript, SCRIPT_ROUTE6GATE_PLAYER_MOVING

Route6GateDefaultScript:
	ld a, [wStatusFlags1]
	bit BIT_GAVE_SAFFRON_GUARDS_DRINK, a
	ret nz
	ld hl, .PlayerInCoordsArray
	call ArePlayerCoordsInArray
	ret nc
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	xor a
	ldh [hJoyHeld], a
	farcall RemoveGuardDrink
	ldh a, [hItemToRemoveID]
	and a
	jr nz, .have_drink
	ld a, TEXT_ROUTE6GATE_GUARD_GEE_IM_THIRSTY
	ldh [hTextID], a
	call DisplayTextID
	call Route6GateMovePlayerDownScript
	ld a, SCRIPT_ROUTE6GATE_PLAYER_MOVING
	ld [wRoute6GateCurScript], a
	ret
.have_drink
	ld hl, wStatusFlags1
	set BIT_GAVE_SAFFRON_GUARDS_DRINK, [hl]
	ld a, TEXT_ROUTE6GATE_GUARD_GIVE_DRINK
	ldh [hTextID], a
	jp DisplayTextID

.PlayerInCoordsArray:
	dbmapcoord  3,  2
	dbmapcoord  4,  2
	db -1 ; end

Route6GatePlayerMovingScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a
	ld [wJoyIgnore], a
	ld [wRoute6GateCurScript], a
	ret

Route6GateMovePlayerDownScript:
	ld hl, wStatusFlags5
	set BIT_SCRIPTED_MOVEMENT_STATE, [hl]
	ld a, PAD_DOWN
	ld [wSimulatedJoypadStatesEnd], a
	ld a, $1
	ld [wSimulatedJoypadStatesIndex], a
	xor a
	ld [wSpritePlayerStateData2MovementByte1], a
	ld [wOverrideSimulatedJoypadStatesMask], a
	ret

Route6Gate_TextPointers:
	def_text_pointers
	dw_const Route6GateGuardText,              TEXT_ROUTE6GATE_GUARD
	dw_const Route6GateLostLetterText,        TEXT_ROUTE6GATE_LOST_LETTER
	dw_const SaffronGateGuardGeeImThirstyText, TEXT_ROUTE6GATE_GUARD_GEE_IM_THIRSTY
	dw_const SaffronGateGuardGiveDrinkText,    TEXT_ROUTE6GATE_GUARD_GIVE_DRINK

Route6GateGuardText:
	text_asm
	CheckEvent EVENT_STARTED_PIDGEY_DELIVERY
	jr z, .original
	CheckEvent EVENT_FOUND_PIDGEY_LETTER
	jr nz, .original
	ld hl, .LetterHintText
	call PrintText
	jp TextScriptEnd
.original
	jp SaffronGateGuardText.script

.LetterHintText:
	text_far _Route6GateGuardLetterHintText
	text_end

Route6GateLostLetterText:
	text_asm
	CheckEvent EVENT_STARTED_PIDGEY_DELIVERY
	jr z, .done
	CheckEvent EVENT_FOUND_PIDGEY_LETTER
	jr nz, .done
	ld hl, .FoundText
	call PrintText
	SetEvent EVENT_FOUND_PIDGEY_LETTER
	call UpdateSprites
.done
	jp TextScriptEnd

.FoundText:
	text_far _Route6GateLostLetterText
	sound_get_key_item
	text_end
