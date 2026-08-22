	object_const_def
	const_export BILLSSECRETGARDEN_PIKACHU

BillsSecretGarden_Object:
	db $a ; border block

	def_warp_events
	warp_event  9, 13, ROUTE_25, 1

	def_bg_events
	bg_event 15,  5, TEXT_BILLSSECRETGARDEN_NOTEBOOK
	bg_event  9, 15, TEXT_BILLSSECRETGARDEN_EXIT

	def_object_events
	object_event 11,  3, SPRITE_FAIRY, STAY, RIGHT, TEXT_BILLSSECRETGARDEN_PIKACHU

	def_warps_to BILLS_SECRET_GARDEN
