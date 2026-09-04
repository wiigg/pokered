; A temporary screen, not a map: the caller restores the route and its graphics.
DrawSnorlaxDreamBanquet::
	ld hl, vTileset
	ld de, RedsHouse1_GFX
	lb bc, BANK(RedsHouse1_GFX), $40
	call CopyVideoData
	ld hl, vTileset tile $40
	ld de, SnorlaxSprite
	lb bc, BANK(SnorlaxSprite), 4
	call CopyVideoData
	ld hl, vTileset tile $44
	ld de, MoveAnimationTiles0 tile $4e ; the original Safari food graphic
	lb bc, BANK(MoveAnimationTiles0), 1
	call CopyVideoData

	; Red's kitchen table stretches past both edges, with no room beneath it.
	hlcoord 0, 7
	ld a, $27
	ld bc, SCREEN_WIDTH
	call FillMemory
	hlcoord 0, 8
	ld a, $2a
	ld bc, SCREEN_WIDTH
	call FillMemory
	hlcoord 0, 9
	ld a, $3a
	ld bc, SCREEN_WIDTH
	call FillMemory
	hlcoord 9, 10
	ld a, $40
	ld [hli], a
	inc a
	ld [hl], a
	hlcoord 9, 11
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	ret

AnimateSnorlaxDreamBanquet::
	ld b, 3
.course
	push bc
	ld a, ' '
	hlcoord 3, 6
	call SnorlaxDreamFoodRow
	ld c, 12
	call DelayFrames
	hlcoord 3, 0
	ld b, 6
.fall
	push bc
	push hl
	ld a, $44
	call SnorlaxDreamFoodRow
	ld c, 8
	call DelayFrames
	pop hl
	push hl
	ld a, ' '
	call SnorlaxDreamFoodRow
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	pop bc
	dec b
	jr nz, .fall
	ld a, $44
	call SnorlaxDreamFoodRow
	ld c, 20
	call DelayFrames
	pop bc
	dec b
	jr nz, .course
	ret

SnorlaxDreamFoodRow:
	ld [hl], a
	ld de, 6
	add hl, de
	ld [hl], a
	add hl, de
	ld [hl], a
	ret
