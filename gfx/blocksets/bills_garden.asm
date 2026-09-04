; An uneven pond bank, using stock water, rock edging and ground tiles.
	assert @ - Overworld_Block == GARDEN_POND_SHALLOWS * 16
	db $32, $14, $14, $14
	db $33, $33, $14, $14
	db $39, $39, $33, $33
	db $39, $39, $39, $39

	assert @ - Overworld_Block == GARDEN_POND_SOUTH_BANK * 16
	db $14, $14, $14, $14
	db $14, $14, $14, $14
	db $14, $14, $14, $14
	db $33, $33, $33, $33

	assert @ - Overworld_Block == GARDEN_POND_SOUTHEAST_BANK * 16
	db $14, $14, $14, $54
	db $14, $14, $14, $54
	db $14, $14, $33, $39
	db $33, $33, $39, $39
