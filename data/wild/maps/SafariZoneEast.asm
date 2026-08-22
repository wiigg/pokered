SafariZoneEastWildMons:
	def_grass_wildmons 30 ; encounter rate
	db 22, PARAS
	db 24, EXEGGCUTE
	db 23, VENONAT
	db 24, TANGELA
	db 28, PARASECT
	db 30, VENOMOTH
	db 27, EXEGGCUTE
IF DEF(_RED)
	db 28, SCYTHER
	db 28, PINSIR
ENDC
IF DEF(_BLUE)
	db 28, PINSIR
	db 28, SCYTHER
ENDC
	db 28, FARFETCHD
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
