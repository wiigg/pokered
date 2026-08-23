CheckForNoBikingMusicMap::
; Keep the area's music on the final approach to the Pokémon League.
	ld a, [wCurMap]
	cp ROUTE_23
	jr z, .found
	cp VICTORY_ROAD_1F
	jr z, .found
	cp VICTORY_ROAD_2F
	jr z, .found
	cp VICTORY_ROAD_3F
	jr z, .found
	cp INDIGO_PLATEAU
	jr z, .found
	and a
	ret
.found
	scf
	ret

CompareMapMusicBankWithCurrentBank::
; Compares the map music's audio ROM bank with the current audio ROM bank
; and updates the audio ROM bank variables.
; d = fade-out counter
; Returns whether the banks are different in carry.
	ld a, [wMapMusicROMBank]
	ld e, a
	ld a, [wAudioROMBank]
	cp e
	jr nz, .differentBanks
	ld [wAudioSavedROMBank], a
	and a
	ret
.differentBanks
	ld a, d ; this is a fade-out counter value and it's always non-zero
	and a
	ld a, e
	jr nz, .next
; If the fade-counter is non-zero, we don't change the audio ROM bank because
; it's needed to keep playing the music as it fades out. The FadeOutAudio
; routine will take care of copying [wAudioSavedROMBank] to [wAudioROMBank]
; when the music has faded out.
	ld [wAudioROMBank], a
.next
	ld [wAudioSavedROMBank], a
	scf
	ret
