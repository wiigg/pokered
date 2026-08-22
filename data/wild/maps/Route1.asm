Route1WildMons:
	def_grass_wildmons 25 ; encounter rate
	db  3, PIDGEY
	db  3, RATTATA
	db  2, RATTATA
	db  2, PIDGEY
	db  3, PIDGEY
	db  3, RATTATA
	db  4, PIDGEY
	db  4, RATTATA
	db  4, SPEAROW
IF DEF(_RED)
	db  4, NIDORAN_M
ENDC
IF DEF(_BLUE)
	db  4, NIDORAN_F
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
