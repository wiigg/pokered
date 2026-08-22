Route13WildMons:
	def_grass_wildmons 20 ; encounter rate
IF DEF(_RED)
	db 24, ODDISH
	db 25, VENONAT
	db 27, PIDGEOTTO
	db 25, DITTO
	db 26, ODDISH
	db 27, VENONAT
	db 28, GLOOM
	db 28, DITTO
	db 30, VENOMOTH
	db 30, TANGELA
ENDC
IF DEF(_BLUE)
	db 24, BELLSPROUT
	db 25, VENONAT
	db 27, PIDGEOTTO
	db 25, DITTO
	db 26, BELLSPROUT
	db 27, VENONAT
	db 28, WEEPINBELL
	db 28, DITTO
	db 30, VENOMOTH
	db 30, TANGELA
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
