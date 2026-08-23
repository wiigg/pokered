Museum2F_Script:
	jp EnableAutoTextBoxDrawing

Museum2F_TextPointers:
	def_text_pointers
	dw_const Museum2FYoungsterText,        TEXT_MUSEUM2F_YOUNGSTER
	dw_const Museum2FGrampsText,           TEXT_MUSEUM2F_GRAMPS
	dw_const Museum2FScientistText,        TEXT_MUSEUM2F_SCIENTIST
	dw_const Museum2FBrunetteGirlText,     TEXT_MUSEUM2F_BRUNETTE_GIRL
	dw_const Museum2FHikerText,            TEXT_MUSEUM2F_HIKER
	dw_const Museum2FSpaceShuttleSignText, TEXT_MUSEUM2F_SPACE_SHUTTLE_SIGN
	dw_const Museum2FMoonStoneSignText,    TEXT_MUSEUM2F_MOON_STONE_SIGN

Museum2FYoungsterText:
	text_far _Museum2FYoungsterText
	text_end

Museum2FGrampsText:
	text_far _Museum2FGrampsText
	text_end

Museum2FScientistText:
	text_far _Museum2FScientistText
	text_end

Museum2FBrunetteGirlText:
	text_far _Museum2FBrunetteGirlText
	text_end

Museum2FHikerText:
	text_far _Museum2FHikerText
	text_end

Museum2FSpaceShuttleSignText:
	text_far _Museum2FSpaceShuttleSignText
	text_end

Museum2FMoonStoneSignText:
	text_asm
	CheckEvent EVENT_COMPLETED_MT_MOON_MOONFALL_CEREMONY
	ld hl, .Text
	jr z, .print_text
	ld hl, .MoonfallText
	call PrintText
	ld a, [wPartySpecies]
	cp CLEFAIRY
	jr z, .clefairy_family
	cp CLEFABLE
	jp nz, TextScriptEnd
.clefairy_family
	call PlayCry
	call WaitForSoundToFinish
	xor a
	ld hl, wPartyMonNicks
	call GetPartyMonName
	ld hl, .ClefairyReactionText
.print_text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _Museum2FMoonStoneSignText
	text_end

.MoonfallText:
	text_far _Museum2FMoonStoneAfterMoonfallText
	text_end

.ClefairyReactionText:
	text_far _Museum2FMoonStoneClefairyReactionText
	text_end
