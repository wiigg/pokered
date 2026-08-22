Route14WildMons:
	def_grass_wildmons 15 ; encounter rate
	db 24, PIDGEY
	db 25, SPEAROW
	db 26, PIDGEOTTO
	db 24, VENONAT
IF DEF(_RED)
	db 25, ODDISH
ENDC
IF DEF(_BLUE)
	db 25, BELLSPROUT
ENDC
	db 27, DODUO
	db 28, PIDGEOTTO
IF DEF(_RED)
	db 28, GLOOM
ENDC
IF DEF(_BLUE)
	db 28, WEEPINBELL
ENDC
	db 30, FEAROW
	db 31, DODRIO
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
