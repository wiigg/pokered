Route2WildMons:
	def_grass_wildmons 25 ; encounter rate
IF DEF(_RED)
	db  3, RATTATA
	db  3, PIDGEY
	db  4, WEEDLE
	db  4, PIDGEY
	db  4, RATTATA
	db  5, WEEDLE
	db  5, PIDGEY
	db  5, WEEDLE
	db  5, KAKUNA
	db  5, PIKACHU
ENDC
IF DEF(_BLUE)
	db  3, RATTATA
	db  3, PIDGEY
	db  4, CATERPIE
	db  4, PIDGEY
	db  4, RATTATA
	db  5, CATERPIE
	db  5, PIDGEY
	db  5, CATERPIE
	db  5, METAPOD
	db  5, PIKACHU
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
