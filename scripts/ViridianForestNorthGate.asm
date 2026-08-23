ViridianForestNorthGate_Script:
	jp EnableAutoTextBoxDrawing

ViridianForestNorthGate_TextPointers:
	def_text_pointers
	dw_const ViridianForestNorthGateSuperNerdText, TEXT_VIRIDIANFORESTNORTHGATE_SUPER_NERD
	dw_const ViridianForestNorthGateGrampsText,    TEXT_VIRIDIANFORESTNORTHGATE_GRAMPS

ViridianForestNorthGateSuperNerdText:
	text_asm
	ld a, TRADE_FOR_CHIKUCHIKU
	ld [wWhichTrade], a
	predef DoInGameTradeDialogue
	jp TextScriptEnd

ViridianForestNorthGateGrampsText:
	text_far _ViridianForestNorthGateGrampsText
	text_end
