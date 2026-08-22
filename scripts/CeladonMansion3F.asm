CeladonMansion3F_Script:
	jp EnableAutoTextBoxDrawing

CeladonMansion3F_TextPointers:
	def_text_pointers
	dw_const CeladonMansion3FProgrammerText,     TEXT_CELADONMANSION3F_PROGRAMMER
	dw_const CeladonMansion3FGraphicArtistText,  TEXT_CELADONMANSION3F_GRAPHIC_ARTIST
	dw_const CeladonMansion3FWriterText,         TEXT_CELADONMANSION3F_WRITER
	dw_const CeladonMansion3FGameDesignerText,   TEXT_CELADONMANSION3F_GAME_DESIGNER
	dw_const CeladonMansion3FGameProgramPCText,  TEXT_CELADONMANSION3F_GAME_PROGRAM_PC
	dw_const CeladonMansion3FPlayingGamePCText,  TEXT_CELADONMANSION3F_PLAYING_GAME_PC
	dw_const CeladonMansion3FGameScriptPCText,   TEXT_CELADONMANSION3F_GAME_SCRIPT_PC
	dw_const CeladonMansion3FDevRoomSignText,    TEXT_CELADONMANSION3F_DEV_ROOM_SIGN

CeladonMansion3FProgrammerText:
	text_far _CeladonMansion3FProgrammerText
	text_end

CeladonMansion3FGraphicArtistText:
	text_far _CeladonMansion3FGraphicArtistText
	text_end

CeladonMansion3FWriterText:
	text_far _CeladonMansion3FWriterText
	text_end

CeladonMansion3FGameDesignerText:
	text_asm
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	ld a, [wNumSetBits]
	cp NUM_POKEMON
	jr nc, .all_151
	cp NUM_POKEMON - 1 ; discount Mew
	jr nc, .completed_dex
	ld hl, .Text
	jr .done
.completed_dex
	ld hl, .CompletedDexText
	jr .done
.all_151
	CheckEvent EVENT_COMPLETED_POKEDEX_EPILOGUE
	ld hl, .All151BeforeOakText
	jr z, .done
	ld hl, .All151AfterOakText
.done
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _CeladonMansion3FGameDesignerText
	text_end

.CompletedDexText:
	text_far _CeladonMansion3FGameDesignerCompletedDexText
	text_promptbutton
	text_asm
	callfar DisplayDiploma
	ld a, TRUE
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd

.All151BeforeOakText:
	text_far _CeladonMansion3FGameDesignerAll151BeforeOakText
	text_promptbutton
	text_asm
	callfar DisplayDiploma
	ld a, TRUE
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd

.All151AfterOakText:
	text_far _CeladonMansion3FGameDesignerAll151AfterOakText
	text_promptbutton
	text_asm
	callfar DisplayDiploma
	ld a, TRUE
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd

CeladonMansion3FGameProgramPCText:
	text_asm
	ld hl, .OriginalText
	ld a, [wNumHoFTeams]
	and a
	jr z, .print
	ld hl, .Pokemon2Text
.print
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _CeladonMansion3FGameProgramPCText
	text_end

.Pokemon2Text:
	text_far _CeladonMansion3FPokemon2Text
	text_end

CeladonMansion3FPlayingGamePCText:
	text_far _CeladonMansion3FPlayingGamePCText
	text_end

CeladonMansion3FGameScriptPCText:
	text_far _CeladonMansion3FGameScriptPCText
	text_end

CeladonMansion3FDevRoomSignText:
	text_far _CeladonMansion3FDevRoomSignText
	text_end
