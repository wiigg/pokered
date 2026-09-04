; Call after MoveSprite, with its object still in hSpriteIndex. The caller owns
; the input lock and hides departing actors. No new map or saved state is used.
WaitForSceneSpriteMovement::
	ld a, [wFontLoaded]
	push af
	res BIT_FONT_LOADED, a
	ld [wFontLoaded], a
	ldh a, [hSpriteIndex]
	push af
	ld a, SPRITESTATEDATA1_MOVEMENTSTATUS
	ldh [hSpriteDataOffset], a
	call GetPointerWithinSpriteStateData1
	ld [hl], 1
	ld c, 192
.frame
	push bc
	call UpdateSprites
	call DelayFrame
	pop bc
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	jr z, .done
	; Leaving the screen is a normal end to a departure animation.
	ld a, SPRITESTATEDATA1_IMAGEINDEX
	ldh [hSpriteDataOffset], a
	call GetPointerWithinSpriteStateData1
	ld a, [hl]
	cp $ff
	jr z, .done
	dec c
	jr nz, .frame
.done
	pop af
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld a, SPRITESTATEDATA1_MOVEMENTSTATUS
	ldh [hSpriteDataOffset], a
	call GetPointerWithinSpriteStateData1
	ld [hl], 1
	inc l
	inc l
	xor a
	ld [hli], a ; Y step vector
	inc l
	ld [hl], a ; X step vector
	ld a, SPRITESTATEDATA2_WALKANIMATIONCOUNTER
	ldh [hSpriteDataOffset], a
	call GetPointerWithinSpriteStateData2
	xor a
	ld [hl], a
	ld [wNPCNumScriptedSteps], a
	ld [wSimulatedJoypadStatesIndex], a
	ld [wUnusedOverrideSimulatedJoypadStatesIndex], a
	ld hl, wStatusFlags5
	res BIT_SCRIPTED_NPC_MOVEMENT, [hl]
	pop af
	ld [wFontLoaded], a
	ret
