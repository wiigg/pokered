FightingDojo_Script:
	call EnableAutoTextBoxDrawing
	ld hl, FightingDojoTrainerHeaders
	ld de, FightingDojo_ScriptPointers
	ld a, [wFightingDojoCurScript]
	call ExecuteCurMapScriptInTable
	ld [wFightingDojoCurScript], a
	ret

FightingDojoResetScripts:
	xor a ; SCRIPT_FIGHTINGDOJO_DEFAULT
	ld [wJoyIgnore], a
	ld [wFightingDojoCurScript], a
	ld [wCurMapScript], a
	ret

FightingDojo_ScriptPointers:
	def_script_pointers
	dw_const FightingDojoDefaultScript,                SCRIPT_FIGHTINGDOJO_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle,    SCRIPT_FIGHTINGDOJO_START_BATTLE
	dw_const EndTrainerBattle,                         SCRIPT_FIGHTINGDOJO_END_BATTLE
	dw_const FightingDojoKarateMasterPostBattleScript, SCRIPT_FIGHTINGDOJO_KARATE_MASTER_POST_BATTLE
	dw_const FightingDojoTrialSwiftnessPostBattleScript, SCRIPT_FIGHTINGDOJO_TRIAL_SWIFTNESS_POST_BATTLE
	dw_const FightingDojoTrialEndurancePostBattleScript, SCRIPT_FIGHTINGDOJO_TRIAL_ENDURANCE_POST_BATTLE
	dw_const FightingDojoTrialMasteryPostBattleScript,   SCRIPT_FIGHTINGDOJO_TRIAL_MASTERY_POST_BATTLE

FightingDojoDefaultScript:
	CheckEvent EVENT_DEFEATED_FIGHTING_DOJO
	ret nz
	call CheckFightingMapTrainers
	ld a, [wTrainerHeaderFlagBit]
	and a
	ret nz
	CheckEvent EVENT_BEAT_KARATE_MASTER
	ret nz
	xor a
	ldh [hJoyHeld], a
	ld [wSavedCoordIndex], a
	ld a, [wYCoord]
	cp 3
	ret nz
	ld a, [wXCoord]
	cp 4
	ret nz
	ld a, 1
	ld [wSavedCoordIndex], a
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, FIGHTINGDOJO_KARATE_MASTER
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_LEFT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, TEXT_FIGHTINGDOJO_KARATE_MASTER
	ldh [hTextID], a
	call DisplayTextID
	ret

FightingDojoKarateMasterPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, FightingDojoResetScripts
	ld a, [wSavedCoordIndex]
	and a ; nz if the player was at (4, 3), left of the Karate Master
	jr z, .already_facing
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, FIGHTINGDOJO_KARATE_MASTER
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_LEFT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
.already_facing
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	SetEventRange EVENT_BEAT_KARATE_MASTER, EVENT_BEAT_FIGHTING_DOJO_TRAINER_3
	ld a, TEXT_FIGHTINGDOJO_KARATE_MASTER_I_WILL_GIVE_YOU_A_POKEMON
	ldh [hTextID], a
	call DisplayTextID
	xor a ; SCRIPT_FIGHTINGDOJO_DEFAULT
	ld [wJoyIgnore], a
	ld [wFightingDojoCurScript], a
	ld [wCurMapScript], a
	ret

FightingDojoTrialSwiftnessPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, FightingDojoResetScripts
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, FightingDojoTrialOneCompleteText
	call PrintText
	ld hl, FightingDojoTrialEnduranceEndBattleText
	ld a, FIGHTING_DOJO_TRIAL_ENDURANCE_TEAM
	ld b, SCRIPT_FIGHTINGDOJO_TRIAL_ENDURANCE_POST_BATTLE
	jp FightingDojoStartTrialBattle

FightingDojoTrialEndurancePostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, FightingDojoResetScripts
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, FightingDojoTrialTwoCompleteText
	call PrintText
	ld hl, FightingDojoTrialMasteryEndBattleText
	ld a, FIGHTING_DOJO_TRIAL_MASTERY_TEAM
	ld b, SCRIPT_FIGHTINGDOJO_TRIAL_MASTERY_POST_BATTLE
	jp FightingDojoStartTrialBattle

FightingDojoTrialMasteryPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, FightingDojoResetScripts
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, FightingDojoTrialCompleteText
	call PrintText
	predef HealParty
	call GBFadeOutToWhite
	call Delay3
	call GBFadeInFromWhite
	ld hl, FightingDojoTrialPartyRestoredText
	call PrintText
	jp FightingDojoResetScripts

; Start a repeatable trainer battle without touching the Dojo's saved trainer flags.
; a = Blackbelt team, b = post-battle script, hl = end-battle text
FightingDojoStartTrialBattle:
	push af
	push bc
	ld d, h
	ld e, l
	call SaveEndBattleTextPointers
	pop bc
	pop af
	ld [wTrainerNo], a
	ld a, OPP_BLACKBELT
	ld [wCurOpponent], a
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld a, b
	ld [wFightingDojoCurScript], a
	ld [wCurMapScript], a
	xor a
	ld [wJoyIgnore], a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ret

FightingDojo_TextPointers:
	def_text_pointers
	dw_const FightingDojoKarateMasterText,                          TEXT_FIGHTINGDOJO_KARATE_MASTER
	dw_const FightingDojoBlackbelt1Text,                            TEXT_FIGHTINGDOJO_BLACKBELT1
	dw_const FightingDojoBlackbelt2Text,                            TEXT_FIGHTINGDOJO_BLACKBELT2
	dw_const FightingDojoBlackbelt3Text,                            TEXT_FIGHTINGDOJO_BLACKBELT3
	dw_const FightingDojoBlackbelt4Text,                            TEXT_FIGHTINGDOJO_BLACKBELT4
	dw_const FightingDojoHitmonleePokeBallText,                     TEXT_FIGHTINGDOJO_HITMONLEE_POKE_BALL
	dw_const FightingDojoHitmonchanPokeBallText,                    TEXT_FIGHTINGDOJO_HITMONCHAN_POKE_BALL
	dw_const FightingDojoKarateMasterText.IWillGiveYouAPokemonText, TEXT_FIGHTINGDOJO_KARATE_MASTER_I_WILL_GIVE_YOU_A_POKEMON

FightingDojoTrainerHeaders:
	def_trainers 2
FightingDojoTrainerHeader0:
	trainer EVENT_BEAT_FIGHTING_DOJO_TRAINER_0, 4, FightingDojoBlackbelt1BattleText, FightingDojoBlackbelt1EndBattleText, FightingDojoBlackbelt1AfterBattleText
FightingDojoTrainerHeader1:
	trainer EVENT_BEAT_FIGHTING_DOJO_TRAINER_1, 4, FightingDojoBlackbelt2BattleText, FightingDojoBlackbelt2EndBattleText, FightingDojoBlackbelt2AfterBattleText
FightingDojoTrainerHeader2:
	trainer EVENT_BEAT_FIGHTING_DOJO_TRAINER_2, 3, FightingDojoBlackbelt3BattleText, FightingDojoBlackbelt3EndBattleText, FightingDojoBlackbelt3AfterBattleText
FightingDojoTrainerHeader3:
	trainer EVENT_BEAT_FIGHTING_DOJO_TRAINER_3, 3, FightingDojoBlackbelt4BattleText, FightingDojoBlackbelt4EndBattleText, FightingDojoBlackbelt4AfterBattleText
	db -1 ; end

FightingDojoKarateMasterText:
	text_asm
	CheckEvent EVENT_DEFEATED_FIGHTING_DOJO
	jp nz, .defeated_dojo
	CheckEventReuseA EVENT_BEAT_KARATE_MASTER
	jp nz, .defeated_master
	ld hl, .Text
	call PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .DefeatedText
	ld de, .DefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, SCRIPT_FIGHTINGDOJO_KARATE_MASTER_POST_BATTLE
	ld [wFightingDojoCurScript], a
	ld [wCurMapScript], a
	jr .end
.defeated_dojo
	ld a, [wNumHoFTeams]
	and a
	jr z, .stay_and_train
	jr .offer_trial
.defeated_master
	ld a, [wNumHoFTeams]
	and a
	jr z, .give_pokemon
	ld hl, .PrizeStillWaitsText
	call PrintText
.offer_trial
	ld hl, .TrialOfferText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .declined_trial
	ld hl, .TrialAcceptedText
	call PrintText
	ld hl, FightingDojoTrialSwiftnessEndBattleText
	ld a, FIGHTING_DOJO_TRIAL_SWIFTNESS_TEAM
	ld b, SCRIPT_FIGHTINGDOJO_TRIAL_SWIFTNESS_POST_BATTLE
	call FightingDojoStartTrialBattle
	jr .end
.declined_trial
	ld hl, .TrialDeclinedText
	call PrintText
	jr .end
.stay_and_train
	ld hl, .StayAndTrainWithUsText
	call PrintText
	jr .end
.give_pokemon
	ld hl, .IWillGiveYouAPokemonText
	call PrintText
.end
	jp TextScriptEnd

.Text:
	text_far _FightingDojoKarateMasterText
	text_end

.DefeatedText:
	text_far _FightingDojoKarateMasterDefeatedText
	text_end

.IWillGiveYouAPokemonText:
	text_far _FightingDojoKarateMasterIWillGiveYouAPokemonText
	text_end

.StayAndTrainWithUsText:
	text_far _FightingDojoKarateMasterStayAndTrainWithUsText
	text_end

.TrialOfferText:
	text_far _FightingDojoKarateMasterTrialOfferText
	text_end

.TrialAcceptedText:
	text_far _FightingDojoKarateMasterTrialAcceptedText
	text_end

.TrialDeclinedText:
	text_far _FightingDojoKarateMasterTrialDeclinedText
	text_end

.PrizeStillWaitsText:
	text_far _FightingDojoKarateMasterPrizeStillWaitsText
	text_end

FightingDojoTrialSwiftnessEndBattleText:
	text_far _FightingDojoTrialSwiftnessEndBattleText
	text_end

FightingDojoTrialEnduranceEndBattleText:
	text_far _FightingDojoTrialEnduranceEndBattleText
	text_end

FightingDojoTrialMasteryEndBattleText:
	text_far _FightingDojoTrialMasteryEndBattleText
	text_end

FightingDojoTrialOneCompleteText:
	text_far _FightingDojoTrialOneCompleteText
	text_end

FightingDojoTrialTwoCompleteText:
	text_far _FightingDojoTrialTwoCompleteText
	text_end

FightingDojoTrialCompleteText:
	text_far _FightingDojoTrialCompleteText
	text_end

FightingDojoTrialPartyRestoredText:
	text_far _FightingDojoTrialPartyRestoredText
	text_end

FightingDojoBlackbelt1Text:
	text_asm
	ld hl, FightingDojoTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

FightingDojoBlackbelt1BattleText:
	text_far _FightingDojoBlackbelt1BattleText
	text_end

FightingDojoBlackbelt1EndBattleText:
	text_far _FightingDojoBlackbelt1EndBattleText
	text_end

FightingDojoBlackbelt1AfterBattleText:
	text_far _FightingDojoBlackbelt1AfterBattleText
	text_end

FightingDojoBlackbelt2Text:
	text_asm
	ld hl, FightingDojoTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

FightingDojoBlackbelt2BattleText:
	text_far _FightingDojoBlackbelt2BattleText
	text_end

FightingDojoBlackbelt2EndBattleText:
	text_far _FightingDojoBlackbelt2EndBattleText
	text_end

FightingDojoBlackbelt2AfterBattleText:
	text_far _FightingDojoBlackbelt2AfterBattleText
	text_end

FightingDojoBlackbelt3Text:
	text_asm
	ld hl, FightingDojoTrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

FightingDojoBlackbelt3BattleText:
	text_far _FightingDojoBlackbelt3BattleText
	text_end

FightingDojoBlackbelt3EndBattleText:
	text_far _FightingDojoBlackbelt3EndBattleText
	text_end

FightingDojoBlackbelt3AfterBattleText:
	text_far _FightingDojoBlackbelt3AfterBattleText
	text_end

FightingDojoBlackbelt4Text:
	text_asm
	ld hl, FightingDojoTrainerHeader3
	call TalkToTrainer
	jp TextScriptEnd

FightingDojoBlackbelt4BattleText:
	text_far _FightingDojoBlackbelt4BattleText
	text_end

FightingDojoBlackbelt4EndBattleText:
	text_far _FightingDojoBlackbelt4EndBattleText
	text_end

FightingDojoBlackbelt4AfterBattleText:
	text_far _FightingDojoBlackbelt4AfterBattleText
	text_end

FightingDojoHitmonleePokeBallText:
	text_asm
	CheckEvent EVENT_GOT_HITMONLEE
	jr z, .GetMon
	ld hl, FightingDojoAlreadyTookPokemonText
	call PrintText
	jr .done
.GetMon
	ld a, HITMONLEE
	call DisplayPokedex
	ld hl, .Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .done
	ld a, [wCurPartySpecies]
	ld b, a
	ld c, 30
	call GivePokemon
	jr nc, .done

	; once Poké Ball is taken, hide sprite
	ld a, TOGGLE_FIGHTING_DOJO_GIFT_1
	ld [wToggleableObjectIndex], a
	predef HideObject
	SetEvents EVENT_GOT_HITMONLEE, EVENT_DEFEATED_FIGHTING_DOJO
.done
	jp TextScriptEnd

.Text:
	text_far _FightingDojoHitmonleePokeBallText
	text_end

FightingDojoHitmonchanPokeBallText:
	text_asm
	CheckEvent EVENT_GOT_HITMONCHAN
	jr z, .GetMon
	ld hl, FightingDojoAlreadyTookPokemonText
	call PrintText
	jr .done
.GetMon
	ld a, HITMONCHAN
	call DisplayPokedex
	ld hl, .Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .done
	ld a, [wCurPartySpecies]
	ld b, a
	ld c, 30
	call GivePokemon
	jr nc, .done
	SetEvents EVENT_GOT_HITMONCHAN, EVENT_DEFEATED_FIGHTING_DOJO

	; once Poké Ball is taken, hide sprite
	ld a, TOGGLE_FIGHTING_DOJO_GIFT_2
	ld [wToggleableObjectIndex], a
	predef HideObject
.done
	jp TextScriptEnd

.Text:
	text_far _FightingDojoHitmonchanPokeBallText
	text_end

FightingDojoAlreadyTookPokemonText:
	text_far _FightingDojoAlreadyTookPokemonText
	text_end
