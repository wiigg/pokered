; A = species, D = existing map object, E = existing toggle ID.
LegendaryVisitorDeparture::
	ld c, a
	ldh a, [hSpriteIndex]
	push af
	ld a, c
	push af
	push de
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, e
	ld [wToggleableObjectIndex], a
	predef ShowObject
	pop de
	pop af
	push de
	push af
	call PlayCry
	call WaitForSoundToFinish
	pop af
	call LegendaryVisitorDepartureEffect
	pop de
	push de
	ld a, d
	ldh [hSpriteIndex], a
	ld de, .TakeOff
	call MoveSprite
	call WaitForSceneSpriteMovement
	pop de
	ld a, e
	ld [wToggleableObjectIndex], a
	predef HideObject
	pop af
	ldh [hSpriteIndex], a
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ret
.TakeOff:
	db NPC_MOVEMENT_UP, NPC_MOVEMENT_UP, NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP, NPC_MOVEMENT_UP, NPC_MOVEMENT_UP, -1

LegendaryVisitorDepartureEffect:
	cp ZAPDOS
	jr z, .electric
	cp ARTICUNO
	jr z, .ice
	; A small horizontal heat shimmer; preserve the camera's sub-tile scroll.
	ldh a, [hSCX]
	push af
	inc a
	ldh [hSCX], a
	ld c, 4
	call DelayFrames
	ldh a, [hSCX]
	sub 2
	ldh [hSCX], a
	ld c, 4
	call DelayFrames
	pop af
	ldh [hSCX], a
	ret
.ice
	ldh a, [rBGP]
	push af
	ld a, %10010000
	ldh [rBGP], a
	ld c, 12
	call DelayFrames
	pop af
	ldh [rBGP], a
	ret
.electric
	ldh a, [rBGP]
	push af
	ld a, %11111100
	ldh [rBGP], a
	ld c, 3
	call DelayFrames
	ld a, %10010000
	ldh [rBGP], a
	ld c, 3
	call DelayFrames
	pop af
	ldh [rBGP], a
	ret
