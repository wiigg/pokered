Route9WildMons:
	def_grass_wildmons 15 ; encounter rate
	db 16, RATTATA
	db 16, SPEAROW
	db 14, RATTATA
IF DEF(_RED)
	db 14, EKANS
	db 17, SPEAROW
	db 16, EKANS
	db 17, RATTATA
	db 16, GEODUDE
	db 16, MACHOP
	db 17, ONIX
ENDC
IF DEF(_BLUE)
	db 14, SANDSHREW
	db 17, SPEAROW
	db 16, SANDSHREW
	db 17, RATTATA
	db 16, GEODUDE
	db 16, MACHOP
	db 17, ONIX
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
