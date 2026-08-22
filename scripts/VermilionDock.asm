VermilionDock_Script:
	call VermilionDockLoadMap
	call EnableAutoTextBoxDrawing
	ld hl, VermilionDock_ScriptPointers
	ld a, [wVermilionDockCurScript]
	jp CallFunctionInTable

VermilionDock_ScriptPointers:
	def_script_pointers
	dw_const VermilionDockDefaultScript,       SCRIPT_VERMILIONDOCK_DEFAULT
	dw_const VermilionDockMewPostBattleScript, SCRIPT_VERMILIONDOCK_MEW_POST_BATTLE

VermilionDockLoadMap:
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	ret z
	CheckEvent EVENT_SS_ANNE_LEFT
	ret z
	ld a, 1
	ld [wNumberOfWarps], a

; Restore the empty harbor because the original departure sequence only clears
; the half of the ship visible while the player is being walked off the map.
	ld a, $d ; water block
	hlowcoord 5, 1, VERMILION_DOCK_WIDTH
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	hlowcoord 5, 2, VERMILION_DOCK_WIDTH
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	CheckEvent EVENT_MOVED_VERMILION_DOCK_TRUCK
	jr z, .redraw
	hlowcoord 10, 0, VERMILION_DOCK_WIDTH
	ld a, $c ; pavement block
	ld [hli], a
	ld [hl], $3 ; truck block, shifted right
.redraw
	farjp RedrawMapView

VermilionDockDefaultScript:
	CheckEventHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	jr nz, .walking_out_of_dock
	CheckEventReuseHL EVENT_GOT_HM01
	ret z
	ld a, [wDestinationWarpID]
	cp $1
	ret nz
	CheckEventReuseHL EVENT_SS_ANNE_LEFT
	jp z, VermilionDockSSAnneLeavesScript
	SetEventReuseHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	call Delay3
	ld hl, wStatusFlags5
	set BIT_SCRIPTED_MOVEMENT_STATE, [hl]
	ld hl, wSimulatedJoypadStatesEnd
	ld a, PAD_UP
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $3
	ld [wSimulatedJoypadStatesIndex], a
	xor a
	ld [wSpritePlayerStateData2MovementByte1], a
	ld [wOverrideSimulatedJoypadStatesMask], a
	dec a
	ld [wJoyIgnore], a
	ret
.walking_out_of_dock
	CheckEventAfterBranchReuseHL EVENT_WALKED_OUT_OF_DOCK, EVENT_STARTED_WALKING_OUT_OF_DOCK
	ret nz
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld [wJoyIgnore], a
	SetEventReuseHL EVENT_WALKED_OUT_OF_DOCK
	ret

VermilionDockMewPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jr z, VermilionDockResetScripts
	ld a, [wBattleWasEscaped]
	and a
	jr nz, VermilionDockResetScripts
	ld a, [wBattleResult]
	and a
	jr z, .defeated
	ld a, [wBattleWasCaptured]
	and a
	jr z, VermilionDockResetScripts
	SetEvent EVENT_BEAT_VERMILION_DOCK_MEW
	jr VermilionDockResetScripts
.defeated
	SetEvent EVENT_BEAT_VERMILION_DOCK_MEW
	ld hl, VermilionDockMewVanishedText
	call PrintText
	; fall through

VermilionDockResetScripts:
	xor a
	ld [wJoyIgnore], a
	ld [wVermilionDockCurScript], a
	ld [wCurMapScript], a
	ret

VermilionDockSSAnneLeavesScript:
	SetEventForceReuseHL EVENT_SS_ANNE_LEFT
	ld a, SFX_STOP_ALL_MUSIC
	ld [wJoyIgnore], a
	ld [wNewSoundID], a
	call PlaySound
	ld c, BANK(Music_Surfing)
	ld a, MUSIC_SURFING
	call PlayMusic
	farcall LoadSmokeTileFourTimes
	xor a
	ld [wSpritePlayerStateData1ImageIndex], a
	ld c, 120
	call DelayFrames
	ld b, HIGH(vBGMap1)
	call CopyScreenTileBufferToVRAM
	hlcoord 0, 10
	ld bc, SCREEN_WIDTH * 6
	ld a, $14 ; water tile
	call FillMemory
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld [wSSAnneSmokeDriftAmount], a
	ldh [rOBP1], a
	ld a, 88
	ld [wSSAnneSmokeX], a
	ld hl, wMapViewVRAMPointer
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	push hl
	ld a, SFX_SS_ANNE_HORN
	call PlaySoundWaitForCurrent
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld d, $0
	ld e, $8
.shift_columns_up
	ld hl, $2
	add hl, bc
	ld a, l
	ld [wMapViewVRAMPointer], a
	ld a, h
	ld [wMapViewVRAMPointer + 1], a
	push hl
	push de
	call ScheduleEastColumnRedraw
	call VermilionDock_EmitSmokePuff
	pop de
	ld b, $10
.smoke_puff_drift_loop
	call VermilionDock_AnimSmokePuffDriftRight
	ld c, $8
.delay_between_drifts
	call VermilionDock_SyncScrollWithLY
	dec c
	jr nz, .delay_between_drifts
	inc d
	dec b
	jr nz, .smoke_puff_drift_loop
	pop bc
	dec e
	jr nz, .shift_columns_up
	xor a
	ldh [rWY], a
	ldh [hWY], a
	call VermilionDock_EraseSSAnne
	ld a, $90
	ldh [hWY], a
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	pop hl
	pop bc
	ld [hl], b
	dec hl
	ld [hl], c
	call LoadPlayerSpriteGraphics
	ld hl, wNumberOfWarps
	dec [hl]
	ret

VermilionDock_AnimSmokePuffDriftRight:
	push bc
	push de
	ld hl, wShadowOAMSprite04XCoord
	ld a, [wSSAnneSmokeDriftAmount]
	swap a
	ld c, a
	ld de, OBJ_SIZE
.drift_loop
	inc [hl]
	inc [hl]
	add hl, de
	dec c
	jr nz, .drift_loop
	pop de
	pop bc
	ret

VermilionDock_EmitSmokePuff:
; new smoke puff above the S.S. Anne's front smokestack
	ld a, [wSSAnneSmokeX]
	sub 16
	ld [wSSAnneSmokeX], a
	ld c, a
	ld b, 100 ; Y
	ld a, [wSSAnneSmokeDriftAmount]
	inc a
	ld [wSSAnneSmokeDriftAmount], a
	ld a, $1
	ld de, VermilionDockOAMBlock
	call WriteOAMBlock
	ret

VermilionDockOAMBlock:
; tile ID, attributes
	db $fc, OAM_PAL1
	db $fd, OAM_PAL1
	db $fe, OAM_PAL1
	db $ff, OAM_PAL1

VermilionDock_SyncScrollWithLY:
	ld h, d
	ld l, $50
	call .sync_scroll_ly
	ld h, $0
	ld l, $80
.sync_scroll_ly
	ldh a, [rLY]
	cp l
	jr nz, .sync_scroll_ly
	ld a, h
	ldh [rSCX], a
.wait_for_ly_match
	ldh a, [rLY]
	cp h
	jr z, .wait_for_ly_match
	ret

VermilionDock_EraseSSAnne:
; Fill the area the S.S. Anne occupies in BG map 0 with water tiles.
	ld hl, wVermilionDockTileMapBuffer
	ld bc, wVermilionDockTileMapBufferEnd - wVermilionDockTileMapBuffer
	ld a, $14 ; water tile
	call FillMemory
	hlbgcoord 0, 10
	ld de, wVermilionDockTileMapBuffer
	lb bc, BANK(wVermilionDockTileMapBuffer), 12
	call CopyVideoData

; Replace the blocks of the lower half of the ship with water blocks. This
; leaves the upper half alone, but that doesn't matter because replacing any of
; the blocks is unnecessary because the blocks the ship occupies are south of
; the player and won't be redrawn when the player automatically walks north and
; exits the map. This code could be removed without affecting anything.
	hlowcoord 5, 2, VERMILION_DOCK_WIDTH
	ld a, $d ; water block
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	ld a, SFX_SS_ANNE_HORN
	call PlaySound
	ld c, 120
	call DelayFrames
	ret

VermilionDockTruckText:
	text_asm
	CheckEvent EVENT_BEAT_VERMILION_DOCK_MEW
	jr nz, .only_tyre_tracks
	ld a, [wElite4Flags]
	bit BIT_BEAT_ELITE_4, a
	jr z, .not_champion
	CheckEvent EVENT_MOVED_VERMILION_DOCK_TRUCK
	jr nz, .start_battle
	ld a, [wStatusFlags1]
	bit BIT_STRENGTH_ACTIVE, a
	jr z, .needs_strength
	call VermilionDockMoveTruck
	ld hl, .TruckMovedText
	call PrintText
.start_battle
	ld hl, .MewAppearedText
	call PrintText
	ld a, MEW
	call PlayCry
	call WaitForSoundToFinish
	ld a, MEW
	ld [wCurOpponent], a
	ld a, 30
	ld [wCurEnemyLevel], a
	ld a, SCRIPT_VERMILIONDOCK_MEW_POST_BATTLE
	ld [wVermilionDockCurScript], a
	ld [wCurMapScript], a
	jp TextScriptEnd
.not_champion
	ld hl, .NotChampionText
	jr .print_text
.needs_strength
	ld hl, .NeedsStrengthText
	jr .print_text
.only_tyre_tracks
	ld hl, .OnlyTyreTracksText
.print_text
	call PrintText
	jp TextScriptEnd

.NotChampionText:
	text_far _VermilionDockTruckNotChampionText
	text_end

.NeedsStrengthText:
	text_far _VermilionDockTruckNeedsStrengthText
	text_end

.TruckMovedText:
	text_far _VermilionDockTruckMovedText
	text_end

.MewAppearedText:
	text_far _VermilionDockMewAppearedText
	text_end

.OnlyTyreTracksText:
	text_far _VermilionDockOnlyTyreTracksText
	text_end

VermilionDockMewVanishedText:
	text_far _VermilionDockMewVanishedText
	text_end

VermilionDockWandererText:
	text_asm
	ld hl, .Text
	call PrintText
	SetEvent EVENT_MET_WANDERER_VERMILION_DOCK
	ld a, TOGGLE_VERMILION_DOCK_WANDERER
	ld [wToggleableObjectIndex], a
	predef HideObject
	jp TextScriptEnd

.Text:
	text_far _VermilionDockWandererText
	text_end

VermilionDockMoveTruck:
	SetEvent EVENT_MOVED_VERMILION_DOCK_TRUCK
	ld a, SFX_PUSH_BOULDER
	call PlaySound
	ld b, 4
	predef PredefShakeScreenHorizontally
	hlowcoord 10, 0, VERMILION_DOCK_WIDTH
	ld a, $c ; pavement block
	ld [hl], a
	ld a, $3 ; truck block
	ld [wNewTileBlockID], a
	lb bc, 0, 11
	predef_jump ReplaceTileBlock

VermilionDock_TextPointers:
	def_text_pointers
	dw_const VermilionDockWandererText, TEXT_VERMILIONDOCK_WANDERER
	dw_const VermilionDockTruckText, TEXT_VERMILIONDOCK_TRUCK
