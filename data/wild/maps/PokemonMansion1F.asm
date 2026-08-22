PokemonMansion1FWildMons:
	def_grass_wildmons 10 ; encounter rate
IF DEF(_RED)
	db 31, KOFFING
	db 30, PONYTA
	db 33, KOFFING
	db 32, GROWLITHE
	db 30, GRIMER
	db 34, PONYTA
	db 35, KOFFING
	db 34, GRIMER
	db 38, WEEZING
	db 39, MUK
ENDC
IF DEF(_BLUE)
	db 31, GRIMER
	db 30, PONYTA
	db 33, GRIMER
	db 32, VULPIX
	db 30, KOFFING
	db 34, PONYTA
	db 35, GRIMER
	db 34, KOFFING
	db 38, MUK
	db 39, WEEZING
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
