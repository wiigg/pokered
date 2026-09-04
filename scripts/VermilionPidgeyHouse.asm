VermilionPidgeyHouse_Script:
	call EnableAutoTextBoxDrawing
	ret

VermilionPidgeyHouse_TextPointers:
	def_text_pointers
	dw_const VermilionPidgeyHouseYoungsterText, TEXT_VERMILIONPIDGEYHOUSE_YOUNGSTER
	dw_const VermilionPidgeyHousePidgeyText,    TEXT_VERMILIONPIDGEYHOUSE_PIDGEY
	dw_const VermilionPidgeyHouseLetterText,    TEXT_VERMILIONPIDGEYHOUSE_LETTER

VermilionPidgeyHouseYoungsterText:
	text_asm
	CheckEvent EVENT_BEAT_SILPH_CO_GIOVANNI
	jr z, .original
	CheckEvent EVENT_DELIVERED_PIDGEY_LETTER
	jr z, .worried
	CheckEvent EVENT_REUNITED_COURIER_PIDGEY
	jr nz, .reward
	ld hl, .ReunionText
	call PrintText
	ld a, PIDGEY
	call PlayCry
	call WaitForSoundToFinish
	SetEvent EVENT_REUNITED_COURIER_PIDGEY
.reward
	CheckEvent EVENT_GOT_PIDGEY_DELIVERY_PP_UP
	jr nz, .after
	ld hl, .RewardOfferText
	call PrintText
	lb bc, PP_UP, 1
	call GiveItem
	jr nc, .bagFull
	SetEvent EVENT_GOT_PIDGEY_DELIVERY_PP_UP
	ld hl, .ReceivedText
	jr .done
.bagFull
	ld hl, .BagFullText
	jr .done
.after
	ld hl, .AfterText
	jr .done
.worried
	ld hl, .WorriedText
	jr .done
.original
	ld hl, .OriginalText
.done
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _VermilionPidgeyHouseYoungsterText
	text_end

.WorriedText:
	text_far _VermilionPidgeyHouseWorriedOwnerText
	text_end

.ReunionText:
	text_far _VermilionPidgeyHouseCourierReunionText
	text_end

.RewardOfferText:
	text_far _VermilionPidgeyHouseRewardOfferText
	text_end

.ReceivedText:
	text_far _VermilionPidgeyHouseReceivedPPUpText
	sound_get_item_1
	text_end

.BagFullText:
	text_far _VermilionPidgeyHouseRewardBagFullText
	text_end

.AfterText:
	text_far _VermilionPidgeyHouseAfterReunionText
	text_end

VermilionPidgeyHousePidgeyText:
	text_far _VermilionPidgeyHousePidgeyText
	text_asm
	ld a, PIDGEY
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

VermilionPidgeyHouseLetterText:
	text_asm
	CheckEvent EVENT_BEAT_SILPH_CO_GIOVANNI
	jr z, .original
	CheckEvent EVENT_REUNITED_COURIER_PIDGEY
	ld hl, .ReplyText
	jr nz, .done
	ld hl, .WritingDeskText
	jr .done
.original
	ld hl, .OriginalText
.done
	call PrintText
	jp TextScriptEnd

.OriginalText:
	text_far _VermilionPidgeyHouseLetterText
	text_end

.WritingDeskText:
	text_far _VermilionPidgeyHouseWritingDeskText
	text_end

.ReplyText:
	text_far _VermilionPidgeyHouseReplyText
	text_end
