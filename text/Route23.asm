_Route23YouDontHaveTheBadgeYetText::
	text "You can pass here"
	line "only if you have"
	cont "the @"
	text_ram wNameBuffer
	text "!"

	para "You don't have the"
	line "@"
	text_ram wNameBuffer
	text " yet!"

	para "You have to have"
	line "it to get to"
	cont "#MON LEAGUE!@"
	text_end

_Route23OhThatIsTheBadgeText::
	text "You can pass here"
	line "only if you have"
	cont "the @"
	text_ram wNameBuffer
	text "!"

	para "Oh! That is the"
	line "@"
	text_ram wNameBuffer
	text "!@"
	text_end

_Route23GoRightAheadText::
	text_start

	para "OK then! Please,"
	line "go right ahead!"
	done

Route23ShortsYoungsterOfferText::
	text "Hi! Remember me?"
	line "I still like"
	cont "shorts!"

	para "My #MON grew"
	line "up, and I kept"
	cont "training!"

	para "Want to see what"
	line "comfy can do?"
	done

Route23ShortsYoungsterAcceptedText::
	text "They're still"
	line "comfy! My #MON"
	cont "aren't!"
	done

Route23ShortsYoungsterDeclinedText::
	text "That's OK!"
	line "I'll keep at it!"
	done

Route23ShortsYoungsterDefeatedText::
	text "I don't"
	line "believe it again!"
	prompt

Route23ShortsYoungsterVictoryText::
	text "See? Shorts make"
	line "you strong!"
	prompt

Route23ShortsYoungsterAfterBattleText::
	text "I trained them"
	line "every single day!"

	para "Good thing shorts"
	line "are comfy and easy"
	cont "to wear!"
	done

_Route23VictoryRoadGateSignText::
	text "VICTORY ROAD GATE"
	line "- #MON LEAGUE"
	done
