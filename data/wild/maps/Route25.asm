Route25WildMons:
	def_grass_wildmons 15 ; encounter rate
IF DEF(_RED)
	db 10, SPEAROW
	db 12, PIDGEY
	db 13, ODDISH
	db 10, GEODUDE
	db 12, ABRA
	db 13, SPEAROW
	db 14, ODDISH
	db 12, NIDORAN_F
	db 14, ABRA
	db 14, CLEFAIRY
ENDC
IF DEF(_BLUE)
	db 10, SPEAROW
	db 12, PIDGEY
	db 13, BELLSPROUT
	db 10, GEODUDE
	db 12, ABRA
	db 13, SPEAROW
	db 14, BELLSPROUT
	db 12, NIDORAN_M
	db 14, ABRA
	db 14, CLEFAIRY
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
