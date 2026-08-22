Route23WildMons:
	def_grass_wildmons 10 ; encounter rate
	db 32, SPEAROW
	db 33, DITTO
IF DEF(_RED)
	db 30, EKANS
ENDC
IF DEF(_BLUE)
	db 30, SANDSHREW
ENDC
	db 38, FEAROW
	db 38, DITTO
IF DEF(_RED)
	db 38, ARBOK
ENDC
IF DEF(_BLUE)
	db 38, SANDSLASH
ENDC
	db 41, FEAROW
	db 41, DITTO
	db 43, RHYDON
	db 43, DRAGONAIR
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
