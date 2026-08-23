TryFieldMove::
	predef GetTileAndCoordsInFrontOfPlayer
	call .TrySurf
	ret z
	jr .TryCut

.TrySurf
	ld a, [wWalkBikeSurfState]
	cp 2
	jr z, .notHandled
	farcall IsNextTileShoreOrWater
	jr c, .notHandled
	ld hl, TilePairCollisionsWater
	call CheckForTilePairCollisions2
	jr c, .notHandled
	ld d, SURF
	call FindPartyMonWithMove
	jr nz, .notHandled
	ld a, [wObtainedBadges]
	bit BIT_SOULBADGE, a
	jr z, .notHandled
	call InitializeFieldMoveTextBox
	farcall IsSurfingAllowed
	ld hl, wStatusFlags1
	bit BIT_SURF_ALLOWED, [hl]
	res BIT_SURF_ALLOWED, [hl]
	jr z, .closeHandled
	ld hl, PromptToSurfText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .closeHandled
	call GetPartyMonName2
	ld a, SURFBOARD
	ld [wCurItem], a
	ld [wPseudoItemID], a
	call UseItem
.closeHandled
	call CloseFieldMoveTextBox
.handled
	xor a
	ret
.notHandled
	ld a, 1
	and a
	ret

.TryCut
	call IsCutTreeInFront
	jr nc, .notHandled
	call InitializeFieldMoveTextBox
	ld hl, ExplainCutText
	call PrintText
	call ManualTextScroll
	ld d, CUT
	call FindPartyMonWithMove
	jr nz, .closeHandled
	ld a, [wObtainedBadges]
	bit BIT_CASCADEBADGE, a
	jr z, .closeHandled
	ld hl, PromptToCutText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .closeHandled
	predef UsedCut
	jr .closeHandled

IsCutTreeInFront:
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	jr z, .overworld
	cp GYM
	jr nz, .no
	ld a, [wTileInFrontOfPlayer]
	cp $50 ; Gym cut tree
	jr z, .yes
	jr .no
.overworld
	ld a, [wTileInFrontOfPlayer]
	cp $3d ; overworld cut tree
	jr nz, .no
.yes
	scf
	ret
.no
	and a
	ret

FindPartyMonWithMove::
; Return Z and select the first party member that knows move d.
	push bc
	push de
	push hl
	ld a, [wPartyCount]
	and a
	jr z, .notFound
	ld b, a
	ld c, 0
	ld hl, wPartyMon1Moves
.monLoop
	ld e, NUM_MOVES
.moveLoop
	ld a, [hli]
	cp d
	jr z, .found
	dec e
	jr nz, .moveLoop
	ld a, PARTYMON_STRUCT_LENGTH - NUM_MOVES
	add l
	ld l, a
	ld a, 0
	adc h
	ld h, a
	inc c
	dec b
	jr nz, .monLoop
.notFound
	ld a, 1
	and a
	jr .done
.found
	ld a, c
	ld [wWhichPokemon], a
	xor a
.done
	pop hl
	pop de
	pop bc
	ret

InitializeFieldMoveTextBox:
	call EnableAutoTextBoxDrawing
	ld a, 1
	ldh [hTextID], a
	farcall DisplayTextIDInit
	ret

CloseFieldMoveTextBox:
	ldh a, [hLoadedROMBank]
	push af
	jp CloseTextDisplay

PromptToSurfText:
	text "The water is calm."
	line "Would you like to"
	cont "SURF?"
	done

ExplainCutText:
	text "This tree can be"
	line "CUT!"
	done

PromptToCutText:
	text "Would you like to"
	line "use CUT?"
	done

TryStrengthFieldMove::
	ld a, [wStatusFlags1]
	bit BIT_STRENGTH_ACTIVE, a
	jr nz, .done
	ld a, [wObtainedBadges]
	bit BIT_RAINBOWBADGE, a
	jr z, .done
	ld d, STRENGTH
	call FindPartyMonWithMove
	jr nz, .done
	ld a, [wWhichPokemon]
	push af
	call ManualTextScroll
	pop af
	ld [wWhichPokemon], a
	call GetPartyMonName2
	predef PrintStrengthText
.done
	jp TextScriptEnd
