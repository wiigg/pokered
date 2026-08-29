UndergroundPathRoute8_Script:
	ld a, ROUTE_8
	ld [wLastMap], a
	jp EnableAutoTextBoxDrawing

UndergroundPathRoute8_TextPointers:
	def_text_pointers
	dw_const UndergroundPathRoute8GirlText, TEXT_UNDERGROUNDPATHROUTE8_GIRL

UndergroundPathRoute8GirlText:
	text_asm
	CheckEvent EVENT_HEARD_UNDERGROUND_PATH_PHANTOM_TRAIN
	ld hl, .HintText
	jr z, .print
	ld hl, .AfterText
.print
	call PrintText
	jp TextScriptEnd

.HintText:
	text_far _UndergroundPathRoute8GirlText
	text_end

.AfterText:
	text_far _UndergroundPathRoute8GirlAfterPhantomTrainText
	text_end
