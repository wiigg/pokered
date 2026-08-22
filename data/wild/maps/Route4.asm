Route4WildMons:
	def_grass_wildmons 20 ; encounter rate
	db 10, RATTATA
	db 10, SPEAROW
IF DEF(_RED)
	db  8, EKANS
	db 10, EKANS
	db 12, RATTATA
	db 12, SPEAROW
	db 12, EKANS
	db 10, PARAS
	db 10, SANDSHREW
	db 10, CLEFAIRY
ENDC
IF DEF(_BLUE)
	db  8, SANDSHREW
	db 10, SANDSHREW
	db 12, RATTATA
	db 12, SPEAROW
	db 12, SANDSHREW
	db 10, PARAS
	db 10, EKANS
	db 10, CLEFAIRY
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
