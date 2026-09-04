SaffronPidgeyHouse_Script:
	CheckEvent EVENT_BEAT_SILPH_CO_GIOVANNI
	jr z, .enableText
	ld a, STAY
	ld [wSprite02StateData2MovementByte1], a
.enableText
	jp EnableAutoTextBoxDrawing

SaffronPidgeyHouse_TextPointers:
	def_text_pointers
	dw_const SaffronPidgeyHouseBrunetteGirlText, TEXT_SAFFRONPIDGEYHOUSE_BRUNETTE_GIRL
	dw_const SaffronPidgeyHousePidgeyText,       TEXT_SAFFRONPIDGEYHOUSE_PIDGEY
	dw_const SaffronPidgeyHouseYoungsterText,    TEXT_SAFFRONPIDGEYHOUSE_YOUNGSTER
	dw_const SaffronPidgeyHousePaperText,        TEXT_SAFFRONPIDGEYHOUSE_PAPER

SaffronPidgeyHouseBrunetteGirlText:
	text_asm
	CheckEvent EVENT_BEAT_SILPH_CO_GIOVANNI
	jr z, .original
	CheckEvent EVENT_DELIVERED_PIDGEY_LETTER
	jr nz, .reply
	CheckEvent EVENT_FOUND_PIDGEY_LETTER
	jr nz, .deliver
	CheckEvent EVENT_STARTED_PIDGEY_DELIVERY
	jr nz, .hint
	SetEvent EVENT_STARTED_PIDGEY_DELIVERY
	ld hl, .ExhaustedText
	jr .done
.hint
	ld hl, .GateHintText
	jr .done
.deliver
	ld hl, .DeliveredText
	call PrintText
	ld a, PIDGEY
	call PlayCry
	call WaitForSoundToFinish
	call GBFadeOutToWhite
	SetEvent EVENT_DELIVERED_PIDGEY_LETTER
	call UpdateSprites
	call GBFadeInFromWhite
	ld hl, .FlewHomeText
	jr .done
.reply
	ld hl, .ReplyReminderText
	CheckEvent EVENT_REUNITED_COURIER_PIDGEY
	jr z, .done
	ld hl, .ReunitedText
	jr .done
.original
	ld hl, .OriginalText
.done
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _SaffronPidgeyHouseBrunetteGirlText
	text_end

.ExhaustedText:
	text_far _SaffronPidgeyHouseExhaustedCourierText
	text_end

.GateHintText:
	text_far _SaffronPidgeyHouseGateHintText
	text_end

.DeliveredText:
	text_far _SaffronPidgeyHouseDeliveredLetterText
	text_end

.FlewHomeText:
	text_far _SaffronPidgeyHouseCourierFlewHomeText
	text_end

.ReplyReminderText:
	text_far _SaffronPidgeyHouseReplyReminderText
	text_end

.ReunitedText:
	text_far _SaffronPidgeyHouseReunitedText
	text_end

SaffronPidgeyHousePidgeyText:
	text_asm
	CheckEvent EVENT_BEAT_SILPH_CO_GIOVANNI
	jr z, .ordinary
	SetEvent EVENT_STARTED_PIDGEY_DELIVERY
	ld hl, .TiredText
	jr .cry
.ordinary
	ld hl, .OriginalText
.cry
	call PrintText
	ld a, PIDGEY
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

.OriginalText:
	text_far _SaffronPidgeyHousePidgeyText
	text_end

.TiredText:
	text_far _SaffronPidgeyHouseTiredPidgeyText
	text_end

SaffronPidgeyHouseYoungsterText:
	text_far _SaffronPidgeyHouseYoungsterText
	text_end

SaffronPidgeyHousePaperText:
	text_far _SaffronPidgeyHousePaperText
	text_end
