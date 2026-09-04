	object_const_def
	const_export BILLSSECRETGARDEN_PIKACHU
	const_export BILLSSECRETGARDEN_NOTEBOOK
	const_export BILLSSECRETGARDEN_CHAIR

BillsSecretGarden_Object:
	db $2c ; solid mountain border beyond the garden

	def_warp_events

	def_bg_events
	bg_event 13,  5, TEXT_BILLSSECRETGARDEN_POND
	bg_event 15,  5, TEXT_BILLSSECRETGARDEN_POND
	bg_event 17,  5, TEXT_BILLSSECRETGARDEN_POND

	def_object_events
	object_event 11,  3, SPRITE_FAIRY, STAY, RIGHT, TEXT_BILLSSECRETGARDEN_PIKACHU
	object_event 14,  6, SPRITE_GARDEN_TABLE, STAY, NONE, TEXT_BILLSSECRETGARDEN_NOTEBOOK
	object_event 14,  7, SPRITE_GARDEN_CHAIR, STAY, NONE, TEXT_BILLSSECRETGARDEN_CHAIR

	def_warps_to BILLS_SECRET_GARDEN

	; destination-only arrival point inside the eastern mountain passage
BillsSecretGarden_Entrance:
	warp_to 15, 16, BILLS_SECRET_GARDEN_WIDTH
