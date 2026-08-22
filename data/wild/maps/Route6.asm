Route6WildMons:
	def_grass_wildmons 15 ; encounter rate
IF DEF(_RED)
	db 13, MANKEY
	db 13, PIDGEY
	db 15, MANKEY
	db 12, ODDISH
	db 15, PIDGEY
	db 16, MANKEY
	db 15, ODDISH
	db 16, PIDGEY
	db 14, MEOWTH
	db 12, DROWZEE
ENDC
IF DEF(_BLUE)
	db 13, MEOWTH
	db 13, PIDGEY
	db 15, MEOWTH
	db 12, BELLSPROUT
	db 15, PIDGEY
	db 16, MEOWTH
	db 15, BELLSPROUT
	db 16, PIDGEY
	db 14, MANKEY
	db 12, DROWZEE
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
