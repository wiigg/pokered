PokemonMansion2FWildMons:
	def_grass_wildmons 10 ; encounter rate
IF DEF(_RED)
	db 32, KOFFING
	db 32, GRIMER
	db 34, KOFFING
	db 31, PONYTA
	db 34, GRIMER
	db 35, KOFFING
	db 38, WEEZING
	db 38, MUK
	db 36, GROWLITHE
	db 39, DITTO
ENDC
IF DEF(_BLUE)
	db 32, GRIMER
	db 32, KOFFING
	db 34, GRIMER
	db 31, PONYTA
	db 34, KOFFING
	db 35, GRIMER
	db 38, MUK
	db 38, WEEZING
	db 36, VULPIX
	db 39, DITTO
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
