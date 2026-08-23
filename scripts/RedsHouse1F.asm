RedsHouse1F_Script:
	jp EnableAutoTextBoxDrawing

RedsHouse1F_TextPointers:
	def_text_pointers
	dw_const RedsHouse1FMomText, TEXT_REDSHOUSE1F_MOM
	dw_const RedsHouse1FTVText,  TEXT_REDSHOUSE1F_TV

RedsHouse1FMomText:
	text_asm
	ld a, [wStatusFlags4]
	bit BIT_GOT_STARTER, a
	jr nz, .heal
	ld hl, .WakeUpText
	call PrintText
	jr .done
.heal
	call RedsHouse1FMomHealScript
.done
	jp TextScriptEnd

.WakeUpText:
	text_far _RedsHouse1FMomWakeUpText
	text_end

RedsHouse1FMomHealScript:
	ld hl, RedsHouse1FMomYouShouldRestText
	ld a, [wNumHoFTeams]
	and a
	jr z, .print_greeting
	ld hl, RedsHouse1FMomChampionHomeText
	ld a, [wPlayerStarter]
	cp STARTER1
	ld de, .CharmanderFamily
	jr z, .check_starter_family
	cp STARTER2
	ld de, .SquirtleFamily
	jr z, .check_starter_family
	cp STARTER3
	jr nz, .print_greeting
	ld de, .BulbasaurFamily
.check_starter_family
	ld a, [wPartySpecies]
	ld b, a
.starter_family_loop
	ld a, [de]
	inc de
	cp -1
	jr z, .print_greeting
	cp b
	jr nz, .starter_family_loop
	ld hl, wPartyMonNicks
	ld de, wNameBuffer
	ld bc, NAME_LENGTH
	call CopyData
	ld hl, RedsHouse1FMomStarterHomeText
.print_greeting
	call PrintText
	call GBFadeOutToWhite
	call ReloadMapData
	predef HealParty
	ld a, MUSIC_PKMN_HEALED
	ld [wNewSoundID], a
	call PlaySound
.next
	ld a, [wChannelSoundIDs]
	cp MUSIC_PKMN_HEALED
	jr z, .next
	ld a, [wMapMusicSoundID]
	ld [wNewSoundID], a
	call PlaySound
	call GBFadeInFromWhite
	ld hl, RedsHouse1FMomLookingGreatText
	jp PrintText

.CharmanderFamily:
	db CHARMANDER, CHARMELEON, CHARIZARD, -1

.SquirtleFamily:
	db SQUIRTLE, WARTORTLE, BLASTOISE, -1

.BulbasaurFamily:
	db BULBASAUR, IVYSAUR, VENUSAUR, -1

RedsHouse1FMomYouShouldRestText:
	text_far _RedsHouse1FMomYouShouldRestText
	text_end
RedsHouse1FMomLookingGreatText:
	text_far _RedsHouse1FMomLookingGreatText
	text_end

RedsHouse1FMomChampionHomeText:
	text_far _RedsHouse1FMomChampionHomeText
	text_end

RedsHouse1FMomStarterHomeText:
	text_far _RedsHouse1FMomStarterHomeText
	text_end

RedsHouse1FTVText:
	text_asm
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ld hl, .WrongSideText
	jr nz, .got_text
	ld hl, .StandByMeMovieText
.got_text
	call PrintText
	jp TextScriptEnd

.StandByMeMovieText:
	text_far _RedsHouse1FTVStandByMeMovieText
	text_end

.WrongSideText:
	text_far _RedsHouse1FTVWrongSideText
	text_end
