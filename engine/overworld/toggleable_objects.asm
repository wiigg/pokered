MarkTownVisitedAndLoadToggleableObjects::
	ld a, [wCurMap]
	cp FIRST_ROUTE_MAP
	jr nc, .notInTown
	ld c, a
	ld b, FLAG_SET
	ld hl, wTownVisitedFlag   ; mark town as visited (for flying)
	predef FlagActionPredef
.notInTown
	ld hl, ToggleableObjectMapPointers
	ld a, [wCurMap]
	ld b, $0
	ld c, a
	add hl, bc
	add hl, bc
	ld a, [hli] ; load toggleable objects pointer in hl
	ld h, [hl]
	ld l, a
	push hl
	ld de, ToggleableObjectStates ; calculate difference between out pointer and the base pointer
	ld a, l
	sub e
	jr nc, .noCarry
	dec h
.noCarry
	ld l, a
	ld a, h
	sub d
	ld h, a
	; divide difference by 3, resulting in the global offset (number of toggleable items before ours)
	ld a, h
	ldh [hDividend], a
	ld a, l
	ldh [hDividend+1], a
	xor a
	ldh [hDividend+2], a
	ldh [hDividend+3], a
	ld a, $3
	ldh [hDivisor], a
	ld b, $2
	call Divide
	ld a, [wCurMap]
	ld b, a
	ldh a, [hDividend+3]
	ld c, a                    ; store global offset in c
	ld de, wToggleableObjectList
	pop hl
.writeToggleableObjectsListLoop
	ld a, [hli]
	cp -1
	jr z, .done     ; end of list
	cp b
	jr nz, .done    ; not for current map anymore
	ld a, [hli]
	inc hl
	ld [de], a                 ; write (map-local) sprite ID
	inc de
	ld a, c
	inc c
	ld [de], a                 ; write (global) toggleable object index
	inc de
	jr .writeToggleableObjectsListLoop
.done
	call LoadSupplementalToggleableObject
	ld a, -1
	ld [de], a                 ; write sentinel
	ret

LoadSupplementalToggleableObject:
	ld hl, SupplementalToggleableObjectStates
	ld c, TOGGLE_MT_MOON_POKECENTER_WANDERER
	ld a, [wCurMap]
	ld b, a
.findMap
	ld a, c
	cp NUM_TOGGLEABLE_OBJECTS
	ret z
	ld a, [hli]
	cp b
	jr z, .found
	inc hl
	inc hl
	inc c
	jr .findMap
.found
	ld a, [hli]
	ld [de], a                 ; map-local object ID
	inc de
	ld a, c
	ld [de], a                 ; global toggleable object index
	inc de
	call IsSupplementalObjectHiddenByEvent
	ld b, FLAG_RESET
	jr z, .applyState
	ld b, FLAG_SET
.applyState
	ld hl, wToggleableObjectFlags
	jp ToggleableObjectFlagAction

IsSupplementalObjectHiddenByEvent:
	ld a, [wCurMap]
	cp ROUTE_20
	jp z, .visitingArticuno
	cp ROUTE_10
	jp z, .visitingZapdos
	cp CINNABAR_ISLAND
	jp z, .visitingMoltres
	cp ROUTE_23
	jp z, .shortsYoungster
	cp REDS_HOUSE_2F
	jp z, .diploma
	CheckEvent EVENT_MET_WANDERER_CERULEAN_CAVE
	ret nz
	ld a, [wCurMap]
	cp MT_MOON_POKECENTER
	jr z, .mtMoon
	cp VERMILION_DOCK
	jr z, .vermilionDock
	cp POKEMON_TOWER_1F
	jr z, .pokemonTower
	cp ROUTE_25
	jr z, .route25
	cp POKEMON_MANSION_B1F
	jr z, .pokemonMansion
	xor a                       ; Cerulean Cave before the reveal
	ret
.visitingArticuno
	CheckEvent EVENT_BEAT_ARTICUNO
	jr nz, .hidden
	lb de, 53, 9
	jr .rollLegendaryVisitor
.visitingZapdos
	CheckEvent EVENT_BEAT_ZAPDOS
	jr nz, .hidden
	lb de, 9, 42
	jr .rollLegendaryVisitor
.visitingMoltres
	CheckEvent EVENT_BEAT_MOLTRES
	jr nz, .hidden
	lb de, 18, 13
.rollLegendaryVisitor
	ld a, [wXCoord]
	cp d
	jr nz, .notOverlappingPlayer
	ld a, [wYCoord]
	cp e
	jr z, .hidden
.notOverlappingPlayer
	ld a, [wStatusFlags4]
	bit BIT_BATTLE_OVER_OR_BLACKOUT, a
	jr nz, .keepLegendaryVisitorState
	call Random
	and %11111 ; one chance in 32 on map entry
	ret
.keepLegendaryVisitorState
	push bc
	ld hl, wToggleableObjectFlags
	ld b, FLAG_TEST
	call ToggleableObjectFlagAction
	ld a, c
	pop bc
	and a
	ret
.mtMoon
	CheckEvent EVENT_MET_WANDERER_MT_MOON
	ret
.vermilionDock
	CheckEvent EVENT_MET_WANDERER_VERMILION_DOCK
	ret nz
	CheckEvent EVENT_GOT_HM01
	ret
.pokemonTower
	CheckEvent EVENT_MET_WANDERER_POKEMON_TOWER
	ret
.route25
	CheckEvent EVENT_MET_WANDERER_ROUTE_25
	ret
.pokemonMansion
	CheckEvent EVENT_MET_WANDERER_POKEMON_MANSION
	ret
.diploma
	CheckEvent EVENT_COMPLETED_POKEDEX_EPILOGUE
	jr nz, .visible
.hidden
	ld a, 1
	and a
	ret
.visible
	xor a
	ret
.shortsYoungster
	CheckEvent EVENT_BEAT_ROUTE_3_TRAINER_1
	jr z, .hidden
	ld a, [wObtainedBadges]
	bit BIT_EARTHBADGE, a
	jr z, .hidden
	; Do not place the returning youngster on top of an imported save's player.
	ld a, [wXCoord]
	cp 13
	jr nz, .visible
	ld a, [wYCoord]
	cp 20
	jr z, .hidden
	jr .visible

InitializeToggleableObjectsFlags:
	ld hl, wToggleableObjectFlags
	ld bc, wToggleableObjectFlagsEnd - wToggleableObjectFlags
	xor a
	call FillMemory ; clear toggleable objects flags
	ld hl, ToggleableObjectStates
	xor a
	ld [wToggleableObjectCounter], a
.toggleableObjectsLoop
	ld a, [hli]
	cp -1 ; end of list
	ret z
	push hl
	inc hl
	ld a, [hl]
	cp OFF
	jr nz, .skip
	ld hl, wToggleableObjectFlags
	ld a, [wToggleableObjectCounter]
	ld c, a
	ld b, FLAG_SET
	call ToggleableObjectFlagAction ; set flag if object is toggled off
.skip
	ld hl, wToggleableObjectCounter
	inc [hl]
	pop hl
	inc hl
	inc hl
	jr .toggleableObjectsLoop

; tests if current object is toggled off/has been hidden
IsObjectHidden:
	ldh a, [hCurrentSpriteOffset]
	swap a
	ld b, a
	ld a, [wCurMap]
	cp VIRIDIAN_GYM
	jr nz, .checkFuchsiaCity
	ld a, b
	cp VIRIDIANGYM_BLUE
	jr nz, .loop
	call IsViridianGymBlueHidden
	jr .done
.checkFuchsiaCity
	cp FUCHSIA_CITY
	jr nz, .loop
	ld a, b
	cp FUCHSIACITY_SARA
	jr nz, .loop
	call IsFuchsiaCitySaraHidden
	jr .done
.loop
	ld hl, wToggleableObjectList

.toggleableObjectLoop
	ld a, [hli]
	cp -1
	jr z, .notHidden ; not toggleable -> not hidden
	cp b
	ld a, [hli]
	jr nz, .toggleableObjectLoop
	ld c, a
	ld b, FLAG_TEST
	ld hl, wToggleableObjectFlags
	call ToggleableObjectFlagAction
	ld a, c
	and a
	jr nz, .hidden
.notHidden
	xor a
.hidden
.done
	ldh [hIsToggleableObjectOff], a
	ret

IsViridianGymBlueHidden:
	ld a, [wNumHoFTeams]
	and a
	jr z, .hidden
	ld a, [wYCoord]
	cp 1
	jr nz, .checkGiovanni
	ld a, [wXCoord]
	cp 2
	jr z, .hidden
.checkGiovanni
	ld hl, wToggleableObjectFlags
	ld c, TOGGLE_VIRIDIAN_GYM_GIOVANNI
	ld b, FLAG_TEST
	call ToggleableObjectFlagAction
	ld a, c
	and a
	jr z, .hidden
	xor a
	ret
.hidden
	ld a, 1
	ret

IsFuchsiaCitySaraHidden:
	CheckEvent EVENT_REUNITED_ERIK_AND_SARA
	jr z, .hidden
	ld a, [wYCoord]
	cp 14
	jr nz, .visible
	ld a, [wXCoord]
	cp 29
	jr z, .hidden
.visible
	xor a
	ret
.hidden
	ld a, 1
	ret

; adds toggleable object (items, leg. pokemon, etc.) to the map
; [wToggleableObjectIndex]: index of the toggleable object to be added (global index)
ShowObject:
ShowObject2:
	ld hl, wToggleableObjectFlags
	ld a, [wToggleableObjectIndex]
	ld c, a
	ld b, FLAG_RESET
	call ToggleableObjectFlagAction   ; reset "removed" flag
	jp UpdateSprites

; removes toggleable object (items, leg. pokemon, etc.) from the map
; [wToggleableObjectIndex]: index of the toggleable object to be removed (global index)
HideObject:
	ld hl, wToggleableObjectFlags
	ld a, [wToggleableObjectIndex]
	ld c, a
	ld b, FLAG_SET
	call ToggleableObjectFlagAction   ; set "removed" flag
	jp UpdateSprites

ToggleableObjectFlagAction:
; identical to FlagAction

	push hl
	push de
	push bc

	; bit
	ld a, c
	ld d, a
	and 7
	ld e, a

	; byte
	ld a, d
	srl a
	srl a
	srl a
	add l
	ld l, a
	jr nc, .ok
	inc h
.ok

	; d = 1 << e (bitmask)
	inc e
	ld d, 1
.shift
	dec e
	jr z, .shifted
	sla d
	jr .shift
.shifted

	ld a, b
	and a
	jr z, .reset
	cp FLAG_TEST
	jr z, .read

; set
	ld a, [hl]
	ld b, a
	ld a, d
	or b
	ld [hl], a
	jr .done

.reset
	ld a, [hl]
	ld b, a
	ld a, d
	xor $ff
	and b
	ld [hl], a
	jr .done

.read
	ld a, [hl]
	ld b, a
	ld a, d
	and b

.done
	pop bc
	pop de
	pop hl
	ld c, a
	ret
