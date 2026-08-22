CeladonHotel_Script:
	call CeladonHotelExposePC
	jp EnableAutoTextBoxDrawing

CeladonHotelExposePC:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_BEAT_CELADON_CHIEF
	ret z

	; A stock save may have the player standing where the visible PC will be.
	ld a, [wXCoord]
	cp 13
	jr nz, .expose
	ld a, [wYCoord]
	cp 3
	ret z
.expose
	ld a, $23 ; right-hand PC block used by ordinary Pokémon Centers
	ld [wNewTileBlockID], a
	lb bc, 1, 6
	predef ReplaceTileBlock
	ld a, $1b ; floor below the PC
	ld [wNewTileBlockID], a
	lb bc, 2, 6
	predef_jump ReplaceTileBlock

CeladonHotelLedgerPC::
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	CheckEvent EVENT_BEAT_CELADON_CHIEF
	jr nz, .openPC
	CheckEvent EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI
	jr z, .openPC
	call EnableAutoTextBoxDrawing
	ld a, 1 << BIT_NO_AUTO_TEXT_BOX
	ld [wAutoTextBoxDrawingControl], a
	tx_pre_jump CeladonHotelLedgerPCText
.openPC
	farjp OpenPokemonCenterPC

CeladonHotelLedgerPCText::
	text_asm
	CheckEvent EVENT_FOUND_CELADON_LEDGER
	jr nz, .alreadyRead
	SetEvent EVENT_FOUND_CELADON_LEDGER
	ld hl, .DiscoveredText
	jr .print
.alreadyRead
	ld hl, .RereadText
.print
	call PrintText
	jp TextScriptEnd

.DiscoveredText:
	text_far _CeladonHotelLedgerDiscoveredText
	text_end

.RereadText:
	text_far _CeladonHotelLedgerRereadText
	text_end

CeladonHotel_TextPointers:
	def_text_pointers
	dw_const CeladonHotelGrannyText,    TEXT_CELADONHOTEL_GRANNY
	dw_const CeladonHotelBeautyText,    TEXT_CELADONHOTEL_BEAUTY
	dw_const CeladonHotelSuperNerdText, TEXT_CELADONHOTEL_SUPER_NERD

CeladonHotelGrannyText:
	text_far _CeladonHotelGrannyText
	text_end

CeladonHotelBeautyText:
	text_far _CeladonHotelBeautyText
	text_end

CeladonHotelSuperNerdText:
	text_asm
	CheckEvent EVENT_BEAT_CELADON_CHIEF
	jr nz, .visiblePC
	CheckEvent EVENT_FOUND_CELADON_LEDGER
	jr nz, .foundLedger
	CheckEvent EVENT_BEAT_ROCKET_HIDEOUT_GIOVANNI
	ld hl, .OriginalText
	jr z, .print
	ld hl, .LedgerHintText
	jr .print
.foundLedger
	ld hl, .FoundLedgerText
	jr .print
.visiblePC
	ld hl, .VisiblePCText
.print
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _CeladonHotelSuperNerdText
	text_end

.LedgerHintText:
	text_far _CeladonHotelSuperNerdLedgerHintText
	text_end

.FoundLedgerText:
	text_far _CeladonHotelSuperNerdFoundLedgerText
	text_end

.VisiblePCText:
	text_far _CeladonHotelSuperNerdVisiblePCText
	text_end
