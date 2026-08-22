Route10WildMons:
	def_grass_wildmons 15 ; encounter rate
	db 16, VOLTORB
	db 16, SPEAROW
	db 14, VOLTORB
IF DEF(_RED)
	db 14, EKANS
	db 17, SPEAROW
	db 16, EKANS
	db 17, VOLTORB
	db 17, EKANS
	db 16, MAGNEMITE
	db 18, PIKACHU
ENDC
IF DEF(_BLUE)
	db 14, SANDSHREW
	db 17, SPEAROW
	db 16, SANDSHREW
	db 17, VOLTORB
	db 17, SANDSHREW
	db 16, MAGNEMITE
	db 18, PIKACHU
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
