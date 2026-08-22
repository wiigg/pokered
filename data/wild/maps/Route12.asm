Route12WildMons:
	def_grass_wildmons 15 ; encounter rate
IF DEF(_RED)
	db 24, ODDISH
	db 24, VENONAT
	db 23, PIDGEY
	db 26, ODDISH
	db 25, VENONAT
	db 27, PIDGEOTTO
	db 28, GLOOM
	db 26, PARAS
	db 30, VENOMOTH
	db 30, FARFETCHD
ENDC
IF DEF(_BLUE)
	db 24, BELLSPROUT
	db 24, VENONAT
	db 23, PIDGEY
	db 26, BELLSPROUT
	db 25, VENONAT
	db 27, PIDGEOTTO
	db 28, WEEPINBELL
	db 26, PARAS
	db 30, VENOMOTH
	db 30, FARFETCHD
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
