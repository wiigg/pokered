BillsSecretGardenWildMons:
	def_grass_wildmons 10 ; encounter rate
IF DEF(_RED)
	db 22, PARAS
	db 23, ODDISH
	db 24, EXEGGCUTE
	db 24, VENONAT
	db 25, TANGELA
	db 26, DITTO
	db 25, ODDISH
	db 28, CHANSEY
	db 25, EEVEE
	db 25, BULBASAUR
ENDC
IF DEF(_BLUE)
	db 22, PARAS
	db 23, BELLSPROUT
	db 24, EXEGGCUTE
	db 24, VENONAT
	db 25, TANGELA
	db 26, DITTO
	db 25, BELLSPROUT
	db 28, CHANSEY
	db 25, EEVEE
	db 25, BULBASAUR
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
