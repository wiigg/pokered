SafariZoneCenterRestHouse_Script:
	jp EnableAutoTextBoxDrawing

SafariZoneCenterRestHouse_TextPointers:
	def_text_pointers
	dw_const SafariZoneCenterRestHouseGirlText,      TEXT_SAFARIZONECENTERRESTHOUSE_GIRL
	dw_const SafariZoneCenterRestHouseScientistText, TEXT_SAFARIZONECENTERRESTHOUSE_SCIENTIST

SafariZoneCenterRestHouseGirlText:
	text_asm
	CheckEvent EVENT_REUNITED_ERIK_AND_SARA
	jr nz, .leaving
	CheckEvent EVENT_ERIK_ASKED_TO_FIND_SARA
	jr nz, .foundErik
	ld hl, .LookingForErikText
	call PrintText
	jr .done
.foundErik
	ld hl, .FoundErikText
	call PrintText
	SetEvent EVENT_REUNITED_ERIK_AND_SARA
	call GBFadeOutToWhite
	call Delay3
	call GBFadeInFromWhite
	jr .done
.leaving
	ld hl, .AfterSaraLeftText
	call PrintText
.done
	jp TextScriptEnd

.LookingForErikText:
	text_far _SafariZoneCenterRestHouseGirlText
	text_end

.FoundErikText:
	text_far _SafariZoneCenterRestHouseGirlFoundErikText
	text_end

.AfterSaraLeftText:
	text_far _SafariZoneCenterRestHouseGirlAfterSaraLeftText
	text_end

SafariZoneCenterRestHouseScientistText:
	text_far _SafariZoneCenterRestHouseScientistText
	text_end
