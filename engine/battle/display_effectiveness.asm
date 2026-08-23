DisplayEffectiveness:
	ld a, [wDamageMultipliers]
	and EFFECTIVENESS_MASK
	ret z
	cp TYPE_IMMUNITY
	ret z
	cp CANCELLED_EFFECTIVENESS
	ret z
	bit BIT_NOT_VERY_EFFECTIVE, a
	ld hl, SuperEffectiveText
	jr z, .done
	ld hl, NotVeryEffectiveText
.done
	jp PrintText

SuperEffectiveText:
	text_far _SuperEffectiveText
	text_end

NotVeryEffectiveText:
	text_far _NotVeryEffectiveText
	text_end
