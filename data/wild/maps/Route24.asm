Route24WildMons:
	def_grass_wildmons 25 ; encounter rate
IF DEF(_RED)
	db  8, WEEDLE
	db 12, ODDISH
	db 12, PIDGEY
	db 10, KAKUNA
	db 13, ODDISH
	db 10, ABRA
	db 13, PIDGEY
	db  8, CATERPIE
	db 12, ABRA
	db 14, PSYDUCK
ENDC
IF DEF(_BLUE)
	db  8, CATERPIE
	db 12, BELLSPROUT
	db 12, PIDGEY
	db 10, METAPOD
	db 13, BELLSPROUT
	db 10, ABRA
	db 13, PIDGEY
	db  8, WEEDLE
	db 12, ABRA
	db 14, PSYDUCK
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
