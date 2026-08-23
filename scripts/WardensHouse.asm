WardensHouse_Script:
	jp EnableAutoTextBoxDrawing

WardensHouse_TextPointers:
	def_text_pointers
	dw_const WardensHouseWardenText,  TEXT_WARDENSHOUSE_WARDEN
	dw_const PickUpItemText,          TEXT_WARDENSHOUSE_RARE_CANDY
	dw_const BoulderText,             TEXT_WARDENSHOUSE_BOULDER
	dw_const WardensHouseDisplayText, TEXT_WARDENSHOUSE_DISPLAY_LEFT
	dw_const WardensHouseDisplayText, TEXT_WARDENSHOUSE_DISPLAY_RIGHT

WardensHouseWardenText:
	text_asm
	CheckEvent EVENT_GOT_HM04
	jr nz, .got_item
	ld b, GOLD_TEETH
	call IsItemInBag
	jr nz, .have_gold_teeth
	CheckEvent EVENT_GAVE_GOLD_TEETH
	jr nz, .gave_gold_teeth
	ld hl, .Gibberish1Text
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, .Gibberish3Text
	jr nz, .refused
	ld hl, .Gibberish2Text
.refused
	call PrintText
	jp .done
.have_gold_teeth
	ld hl, .GaveTheGoldTeethText
	call PrintText
	ld a, GOLD_TEETH
	ldh [hItemToRemoveID], a
	farcall RemoveItemByID
	SetEvent EVENT_GAVE_GOLD_TEETH
.gave_gold_teeth
	ld hl, .ThanksText
	call PrintText
	lb bc, HM_STRENGTH, 1
	call GiveItem
	jr nc, .bag_full
	ld hl, .ReceivedHM04Text
	call PrintText
	SetEvent EVENT_GOT_HM04
	jr .done
.got_item
	ld a, [wElite4Flags]
	bit BIT_BEAT_ELITE_4, a
	jr z, .explainHM04
	CheckEvent EVENT_STARTED_SAFARI_MASTER_CHALLENGE
	jr z, .startSafariMasterChallenge
	CheckEvent EVENT_BECAME_SAFARI_MASTER
	jr nz, .safariMaster
	ld a, [wEventFlags + EVENT_SAFARI_MASTER_CAUGHT_CHANSEY / 8]
	and %00011110 ; the four Safari Master photo bits
	cp %00011110
	jr z, .becomeSafariMaster
	ld hl, .SafariMasterProgressText
	call PrintText
	jr .done
.startSafariMasterChallenge
	ld hl, .SafariMasterIntroText
	call PrintText
	ResetEvents EVENT_SAFARI_MASTER_CAUGHT_CHANSEY, EVENT_SAFARI_MASTER_CAUGHT_KANGASKHAN, EVENT_SAFARI_MASTER_CAUGHT_TAUROS, EVENT_SAFARI_MASTER_CAUGHT_SCYTHER_OR_PINSIR, EVENT_BECAME_SAFARI_MASTER
	SetEvent EVENT_STARTED_SAFARI_MASTER_CHALLENGE
	jr .done
.becomeSafariMaster
	ld hl, .BecameSafariMasterText
	call PrintText
	SetEvent EVENT_BECAME_SAFARI_MASTER
	jr .done
.safariMaster
	ld hl, .SafariMasterText
	call PrintText
	jr .done
.explainHM04
	ld hl, .HM04ExplanationText
	call PrintText
	jr .done
.bag_full
	ld hl, .HM04NoRoomText
	call PrintText
.done
	jp TextScriptEnd

.Gibberish1Text:
	text_far _WardensHouseWardenGibberish1Text
	text_end

.Gibberish2Text:
	text_far _WardensHouseWardenGibberish2Text
	text_end

.Gibberish3Text:
	text_far _WardensHouseWardenGibberish3Text
	text_end

.GaveTheGoldTeethText:
	text_far _WardensHouseWardenGaveTheGoldTeethText
	sound_get_item_1
	text_far _WardensHouseWardenTeethPoppedInHisTeethText
	text_end

.ThanksText:
	text_far _WardensHouseWardenThanksText
	text_end

.ReceivedHM04Text:
	text_far _WardensHouseWardenReceivedHM04Text
	sound_get_item_1
	text_end

.HM04ExplanationText:
	text_far _WardensHouseWardenHM04ExplanationText
	text_end

.HM04NoRoomText:
	text_far _WardensHouseWardenHM04NoRoomText
	text_end

.SafariMasterIntroText:
	text_far _WardensHouseWardenSafariMasterIntroText
	text_end

.SafariMasterProgressText:
	text_far _WardensHouseWardenSafariMasterProgressText
	text_end

.BecameSafariMasterText:
	text_far _WardensHouseWardenBecameSafariMasterText
	text_end

.SafariMasterText:
	text_far _WardensHouseWardenSafariMasterText
	text_end

WardensHouseDisplayText:
	text_asm
	CheckEvent EVENT_STARTED_SAFARI_MASTER_CHALLENGE
	jr nz, .safariMasterDisplay
	ldh a, [hTextID]
	cp TEXT_WARDENSHOUSE_DISPLAY_LEFT
	ld hl, .MerchandiseText
	jr nz, .print_text
	ld hl, .PhotosAndFossilsText
	jr .print_text
.safariMasterDisplay
	ldh a, [hTextID]
	cp TEXT_WARDENSHOUSE_DISPLAY_LEFT
	jr nz, .rightDisplay
	CheckEvent EVENT_SAFARI_MASTER_CAUGHT_CHANSEY
	jr z, .leftWithoutChansey
	CheckEvent EVENT_SAFARI_MASTER_CAUGHT_KANGASKHAN
	ld hl, .LeftBothText
	jr nz, .print_text
	ld hl, .LeftChanseyText
	jr .print_text
.leftWithoutChansey
	CheckEvent EVENT_SAFARI_MASTER_CAUGHT_KANGASKHAN
	ld hl, .LeftKangaskhanText
	jr nz, .print_text
	ld hl, .LeftEmptyText
	jr .print_text
.rightDisplay
	CheckEvent EVENT_SAFARI_MASTER_CAUGHT_TAUROS
	jr z, .rightWithoutTauros
	CheckEvent EVENT_SAFARI_MASTER_CAUGHT_SCYTHER_OR_PINSIR
	ld hl, .RightBothText
	jr nz, .print_text
	ld hl, .RightTaurosText
	jr .print_text
.rightWithoutTauros
	CheckEvent EVENT_SAFARI_MASTER_CAUGHT_SCYTHER_OR_PINSIR
	ld hl, .RightBugText
	jr nz, .print_text
	ld hl, .RightEmptyText
.print_text
	call PrintText
	jp TextScriptEnd

.PhotosAndFossilsText:
	text_far _WardensHouseDisplayPhotosAndFossilsText
	text_end

.MerchandiseText:
	text_far _WardensHouseDisplayMerchandiseText
	text_end

.LeftEmptyText:
	text_far _WardensHouseDisplayLeftEmptyText
	text_end

.LeftChanseyText:
	text_far _WardensHouseDisplayLeftChanseyText
	text_end

.LeftKangaskhanText:
	text_far _WardensHouseDisplayLeftKangaskhanText
	text_end

.LeftBothText:
	text_far _WardensHouseDisplayLeftBothText
	text_end

.RightEmptyText:
	text_far _WardensHouseDisplayRightEmptyText
	text_end

.RightTaurosText:
	text_far _WardensHouseDisplayRightTaurosText
	text_end

.RightBugText:
	text_far _WardensHouseDisplayRightBugText
	text_end

.RightBothText:
	text_far _WardensHouseDisplayRightBothText
	text_end
