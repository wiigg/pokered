CeruleanCave1FWildMons:
	def_grass_wildmons 10 ; encounter rate
	db 46, GOLBAT
	db 46, HYPNO
	db 47, MAGNETON
	db 48, KADABRA
	db 49, VENOMOTH
	db 49, DODRIO
IF DEF(_RED)
	db 50, ARBOK
ENDC
IF DEF(_BLUE)
	db 50, SANDSLASH
ENDC
	db 50, DITTO
	db 52, RAICHU
	db 54, ALAKAZAM
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
