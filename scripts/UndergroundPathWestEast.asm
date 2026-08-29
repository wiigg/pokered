UndergroundPathWestEast_Script:
	call EnableAutoTextBoxDrawing
	CheckEvent EVENT_HEARD_UNDERGROUND_PATH_PHANTOM_TRAIN
	ret nz
	ld hl, .PhantomTrainTriggerCoords
	call ArePlayerCoordsInArray
	ret nc

	xor a
	ldh [hJoyHeld], a
	ld a, PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, SFX_STOP_ALL_MUSIC
	call PlaySound
	ld c, 15
	call DelayFrames

	ld b, 3
	predef ChangeBGPalColor0_4Frames
	ld c, 6
	call DelayFrames
	ld b, 3
	predef ChangeBGPalColor0_4Frames
	ld a, SFX_SS_ANNE_HORN
	call PlaySound
	ld c, 15
	call DelayFrames
	ld a, SFX_PUSH_BOULDER
	call PlaySound
	ld b, 5
	predef PredefShakeScreenHorizontally
	ld b, 2
	predef ChangeBGPalColor0_4Frames
	call WaitForSoundToFinish

	ld a, TEXT_UNDERGROUNDPATHWESTEAST_PHANTOM_TRAIN
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_HEARD_UNDERGROUND_PATH_PHANTOM_TRAIN
	call PlayDefaultMusic
	xor a
	ld [wJoyIgnore], a
	ret

.PhantomTrainTriggerCoords:
	dbmapcoord 24, 1
	dbmapcoord 24, 2
	dbmapcoord 24, 3
	dbmapcoord 24, 4
	dbmapcoord 24, 5
	db -1 ; end

UndergroundPathWestEast_TextPointers:
	def_text_pointers
	dw_const UndergroundPathWestEastPhantomTrainText, TEXT_UNDERGROUNDPATHWESTEAST_PHANTOM_TRAIN

UndergroundPathWestEastPhantomTrainText:
	text_far _UndergroundPathWestEastPhantomTrainText
	text_end
