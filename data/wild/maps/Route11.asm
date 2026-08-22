Route11WildMons:
	def_grass_wildmons 15 ; encounter rate
IF DEF(_RED)
	db 14, EKANS
	db 15, SPEAROW
	db 12, DROWZEE
	db 12, EKANS
	db 13, SPEAROW
	db 13, DROWZEE
	db 15, EKANS
	db 15, DROWZEE
	db 15, KRABBY
	db 16, FARFETCHD
ENDC
IF DEF(_BLUE)
	db 14, SANDSHREW
	db 15, SPEAROW
	db 12, DROWZEE
	db 12, SANDSHREW
	db 13, SPEAROW
	db 13, DROWZEE
	db 15, SANDSHREW
	db 15, DROWZEE
	db 15, KRABBY
	db 16, FARFETCHD
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
