PokemonMansion3FWildMons:
	def_grass_wildmons 10 ; encounter rate
IF DEF(_RED)
	db 32, PONYTA
	db 33, GROWLITHE
	db 34, KOFFING
	db 34, PONYTA
	db 35, GROWLITHE
	db 39, WEEZING
	db 35, GRIMER
	db 38, KOFFING
	db 38, MAGMAR
	db 42, RAPIDASH
ENDC
IF DEF(_BLUE)
	db 32, PONYTA
	db 33, VULPIX
	db 34, GRIMER
	db 34, PONYTA
	db 35, VULPIX
	db 39, MUK
	db 35, KOFFING
	db 38, GRIMER
	db 38, MAGMAR
	db 42, RAPIDASH
ENDC
	end_grass_wildmons

	def_water_wildmons 0 ; encounter rate
	end_water_wildmons
