DisplayOakLabEmailText:
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	call EnableAutoTextBoxDrawing
	CheckEvent EVENT_BEAT_PROF_OAK
	jr nz, .reply
	tx_pre_jump OakLabEmailText
.reply
	tx_pre_jump OakLabEmailReplyText

OakLabEmailText::
	text_far _OakLabEmailText
	text_end

OakLabEmailReplyText::
	text_far _OakLabEmailReplyText
	text_end
