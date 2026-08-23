DEF EXP_BAR_BASE_TILE_ID EQU $c0
DEF EXP_BAR_TILES EQU 8
DEF EXP_BAR_PIXELS EQU EXP_BAR_TILES * 8

PrintEXPBar::
	call CalcEXPBarPixelLength
	ldh a, [hQuotient + 3]
	ld [wEXPBarPixelLength], a

DrawEXPBarTiles:
	ld b, a
	ld c, 8
	ld d, EXP_BAR_TILES
	hlcoord 17, 11
.findPartialTile
	ld a, b
	sub c
	jr nc, .placeTile
	ld c, b
	jr .findPartialTile
.placeTile
	ld b, a
	ld a, EXP_BAR_BASE_TILE_ID
	add c
.fillRemainingTiles
	ld [hld], a
	dec d
	ret z
	ld a, b
	and a
	jr nz, .findPartialTile
	ld a, EXP_BAR_BASE_TILE_ID
	jr .fillRemainingTiles

CalcEXPBarPixelLength:
	ld hl, wEXPBarKeepFullFlag
	bit 0, [hl]
	jr z, .calculate
	res 0, [hl]
	jp .full

.calculate
	ld hl, wPartyMon1Level
	call ActivePartyMonAttribute
	ld a, [hl]
	cp MAX_LEVEL
	jp nc, .full

	ld hl, wPartyMon1Exp
	call ActivePartyMonAttribute
	ld de, wEXPBarCurEXP
	ld bc, 3
	call CopyData

	ld hl, wPartyMon1Species
	call ActivePartyMonAttribute
	ld a, [hl]
	ld [wCurSpecies], a
	call GetMonHeader

	ld hl, wPartyMon1Level
	call ActivePartyMonAttribute
	ld d, [hl]
	callfar CalcExperience
	ld hl, hExperience
	ld de, wEXPBarBaseEXP
	ld bc, 3
	call CopyData

	ld hl, wPartyMon1Level
	call ActivePartyMonAttribute
	ld d, [hl]
	inc d
	callfar CalcExperience
	ld hl, hExperience
	ld de, wEXPBarNeededEXP
	ld bc, 3
	call CopyData

	ld bc, wEXPBarCurEXP
	ld hl, wEXPBarNeededEXP
	call CompareThreeByteNum
	jp nc, .full

	ld bc, wEXPBarCurEXP
	ld hl, wEXPBarBaseEXP
	call CompareThreeByteNum
	jr c, .empty

	ld bc, wEXPBarCurEXP
	ld hl, wEXPBarBaseEXP
	ld de, wEXPBarCurEXP
	call SubThreeByteNum
	ld bc, wEXPBarNeededEXP
	ld hl, wEXPBarBaseEXP
	ld de, wEXPBarNeededEXP
	call SubThreeByteNum

; Scale both values down together until the divisor fits in one byte.
	ld hl, wEXPBarNeededEXP
	ld de, wEXPBarCurEXP + 1
	ld a, [hli]
	and a
	jr z, .twoBytes
	ld a, [hli]
	ld [hld], a
	dec hl
	ld a, [hli]
	ld [hld], a
	ld a, [de]
	inc de
	ld [de], a
	dec de
	dec de
	ld a, [de]
	inc de
	ld [de], a
	dec de
	xor a
	ld [hli], a
	ld [de], a
	inc de
.twoBytes
	ld a, [hl]
	and a
	jr z, .oneByte
	srl a
	ld [hli], a
	ld a, [hl]
	rr a
	ld [hld], a
	ld a, [de]
	srl a
	ld [de], a
	inc de
	ld a, [de]
	rr a
	ld [de], a
	dec de
	jr .twoBytes

.oneByte
	ld hl, hMultiplicand
	ld de, wEXPBarCurEXP
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hl], a
	ld a, EXP_BAR_PIXELS
	ldh [hMultiplier], a
	call Multiply

	ld a, [wEXPBarNeededEXP + 2]
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 3]
	cp EXP_BAR_PIXELS
	ret c
	dec a
	ldh [hQuotient + 3], a
	ret

.empty
	xor a
	ldh [hQuotient + 3], a
	ret

.full
	ld a, EXP_BAR_PIXELS
	ldh [hQuotient + 3], a
	ret

; Compare the three-byte big-endian number at bc with the one at hl.
CompareThreeByteNum:
	ld a, [bc]
	cp [hl]
	ret nz
	inc bc
	inc hl
	ld a, [bc]
	cp [hl]
	ret nz
	inc bc
	inc hl
	ld a, [bc]
	cp [hl]
	ret

; Subtract the three-byte big-endian number at hl from the one at bc,
; storing the result at de.
SubThreeByteNum:
	inc bc
	inc bc
	inc hl
	inc hl
	inc de
	inc de
	ld a, [bc]
	sub [hl]
	ld [de], a
	dec bc
	dec hl
	dec de
	ld a, [bc]
	sbc [hl]
	ld [de], a
	dec bc
	dec hl
	dec de
	ld a, [bc]
	sbc [hl]
	ld [de], a
	ret

AnimateEXPBarAgain:
	call IsCurrentMonBattleMon
	ret nz
	ld hl, wPartyMon1Level
	call ActivePartyMonAttribute
	ld a, [hl]
	cp MAX_LEVEL
	ret nc
	xor a
	ld [wEXPBarPixelLength], a
	call DrawEXPBarTiles

AnimateEXPBar:
	call IsCurrentMonBattleMon
	ret nz
	call CalcEXPBarPixelLength
	ld hl, wEXPBarPixelLength
	ld a, [hl]
	ld b, a
	ldh a, [hQuotient + 3]
	ld [hl], a
	sub b
	jr z, .syncBackup
	jr c, .redraw
	ld b, a
	push bc
	ld a, SFX_HEAL_HP
	call PlaySoundWaitForCurrent
	pop bc
	ld c, EXP_BAR_TILES
	hlcoord 17, 11
.nextPixel
	ld a, [hl]
	cp EXP_BAR_BASE_TILE_ID + 8
	jr nz, .fillPixel
	dec hl
	dec c
	jr z, .animationDone
	jr .nextPixel
.fillPixel
	inc a
	ld [hl], a
	call DelayFrame
	dec b
	jr nz, .nextPixel
.animationDone
	call .syncBackup
	ld c, 8
	jp DelayFrames

.redraw
	ld a, [wEXPBarPixelLength]
	call DrawEXPBarTiles
.syncBackup
	ld bc, EXP_BAR_TILES
	hlcoord 10, 11
	ld de, wTileMapBackup + 10 + 11 * SCREEN_WIDTH
	jp CopyData

KeepEXPBarFull:
	push hl
	call IsCurrentMonBattleMon
	jr nz, .done
	ld hl, wEXPBarKeepFullFlag
	set 0, [hl]

.done
	pop hl
	ret

IsCurrentMonBattleMon:
	ld a, [wPlayerMonNumber]
	ld b, a
	ld a, [wWhichPokemon]
	cp b
	ret

ActivePartyMonAttribute:
	ld a, [wPlayerMonNumber]
	ld bc, PARTYMON_STRUCT_LENGTH
	jp AddNTimes

; Nine lower-border tiles containing zero through eight filled pixels.
EXPBarGraphics::
FOR pixels, 9
	dw 0, 0, 0
	db 0, (1 << pixels) - 1
	db 0, (1 << pixels) - 1
	dw 0
	db $ff, $ff
	dw 0
ENDR
; Reuse the party-screen Poké Ball as the wild-battle caught marker.
ASSERT CAUGHT_BALL_TILE_ID == EXP_BAR_BASE_TILE_ID + EXP_BAR_TILES + 1
INCBIN "gfx/battle/balls.2bpp", 0, TILE_SIZE
EXPBarGraphicsEnd::
