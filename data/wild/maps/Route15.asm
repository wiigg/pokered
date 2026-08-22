Route15WildMons:
	def_grass_wildmons 15 ; encounter rate
IF DEF(_RED)
	db 24, VENONAT
	db 25, ODDISH
	db 26, PIDGEOTTO
	db 27, VENONAT
	db 26, DITTO
	db 28, ODDISH
	db 29, GLOOM
	db 29, DITTO
	db 30, VENOMOTH
	db 30, SCYTHER
ENDC
IF DEF(_BLUE)
	db 24, VENONAT
	db 25, BELLSPROUT
	db 26, PIDGEOTTO
	db 27, VENONAT
	db 26, DITTO
	db 28, BELLSPROUT
	db 29, WEEPINBELL
	db 29, DITTO
	db 30, VENOMOTH
	db 30, PINSIR
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
