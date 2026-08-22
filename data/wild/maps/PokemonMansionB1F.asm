PokemonMansionB1FWildMons:
	def_grass_wildmons 10 ; encounter rate
IF DEF(_RED)
	db 34, KOFFING
	db 34, GRIMER
	db 33, PONYTA
	db 35, GROWLITHE
	db 38, WEEZING
	db 38, MUK
	db 36, DITTO
	db 39, MAGMAR
	db 41, WEEZING
	db 42, DITTO
ENDC
IF DEF(_BLUE)
	db 34, GRIMER
	db 34, KOFFING
	db 33, PONYTA
	db 35, VULPIX
	db 38, MUK
	db 38, WEEZING
	db 36, DITTO
	db 39, MAGMAR
	db 41, MUK
	db 42, DITTO
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
