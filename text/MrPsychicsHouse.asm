_MrPsychicsHouseMrPsychicYouWantedThisText::
	text "...Wait! Don't"
	line "say a word!"

	para "You wanted this!"
	prompt

_MrPsychicsHouseMrPsychicReceivedTM29Text::
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end

_MrPsychicsHouseMrPsychicMoveServiceIntroText::
	text "TM29 is PSYCHIC!"

	para "It can lower the"
	line "target's SPECIAL"
	cont "abilities."

	para "Your #MON's"
	line "memories are also"
	cont "clear to me."

	para "I can awaken a"
	line "natural move, or"
	cont "make one fade."
	done

_MrPsychicsHouseMrPsychicTM29NoRoomText::
	text "Where do you plan"
	line "to put this?"
	done

_MrPsychicsHouseWhichPokemonRememberText::
	text "Which #MON should"
	line "remember a move?"
	prompt

_MrPsychicsHouseWhichMoveRememberText::
	text "Which move should"
	line "I awaken?"
	prompt

_MrPsychicsHouseNoMovesToRememberText::
	text "I sense no lost"
	line "moves to awaken."
	done

_MrPsychicsHouseWhichPokemonForgetText::
	text "Which #MON should"
	line "forget a move?"
	prompt

_MrPsychicsHouseWhichMoveForgetText::
	text "Which move should"
	line "fade away?"
	cont "Even HMs may fade."
	prompt

_MrPsychicsHouseOnlyOneMoveText::
	text "I cannot erase its"
	line "only move."
	done

_MrPsychicsHouseConfirmForgetText::
	text "Should @"
	text_ram wLearnMoveMonName
	text_start
	line "forget"
	cont "@"
	text_ram wStringBuffer
	text "?"
	done

_MrPsychicsHouseForgotMoveText::
	text_ram wLearnMoveMonName
	text " forgot"
	line "@"
	text_ram wStringBuffer
	text "!"
	done
