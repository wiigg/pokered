; super rod encounters
SuperRodData:
	; map, fishing group
	dbw PALLET_TOWN,         .PalletCoast
	dbw VIRIDIAN_CITY,       .ViridianPond
	dbw CERULEAN_CITY,       .CeruleanWaters
	dbw VERMILION_CITY,      .VermilionHarbour
	dbw CELADON_CITY,        .CeladonPond
	dbw FUCHSIA_CITY,        .FuchsiaBay
	dbw CINNABAR_ISLAND,     .CinnabarCoast
	dbw ROUTE_4,             .CeruleanWaters
	dbw ROUTE_6,             .VermilionHarbour
	dbw ROUTE_10,            .Route10Reservoir
	dbw ROUTE_11,            .VermilionHarbour
	dbw ROUTE_12,            .EasternRivers
	dbw ROUTE_13,            .EasternRivers
	dbw ROUTE_17,            .WesternCoast
	dbw ROUTE_18,            .WesternCoast
	dbw ROUTE_19,            .FuchsiaBay
	dbw ROUTE_20,            .SeafoamChannel
	dbw ROUTE_21,            .CinnabarCoast
	dbw ROUTE_22,            .ViridianPond
	dbw ROUTE_23,            .IndigoWaters
	dbw ROUTE_24,            .CeruleanWaters
	dbw ROUTE_25,            .CeruleanWaters
	dbw CERULEAN_GYM,        .CeruleanWaters
	dbw VERMILION_DOCK,      .VermilionHarbour
	dbw SEAFOAM_ISLANDS_B3F, .SeafoamChannel
	dbw SEAFOAM_ISLANDS_B4F, .SeafoamChannel
	dbw SAFARI_ZONE_EAST,    .SafariWaters
	dbw SAFARI_ZONE_NORTH,   .SafariWaters
	dbw SAFARI_ZONE_WEST,    .SafariWaters
	dbw SAFARI_ZONE_CENTER,  .SafariWaters
	dbw CERULEAN_CAVE_2F,    .CeruleanCave
	dbw CERULEAN_CAVE_B1F,   .CeruleanCave
	dbw CERULEAN_CAVE_1F,    .CeruleanCave
	db -1 ; end

; fishing groups
; number of monsters, followed by level/monster pairs

.PalletCoast:
	db 3
	db 20, TENTACOOL
	db 20, HORSEA
	db 20, SHELLDER

.ViridianPond:
	db 2
	db 20, POLIWAG
	db 20, GOLDEEN

.CeruleanWaters:
	db 3
	db 20, POLIWAG
	db 20, GOLDEEN
	db 20, PSYDUCK

.VermilionHarbour:
	db 3
	db 20, KRABBY
	db 20, SHELLDER
	db 20, HORSEA

.CeladonPond:
	db 3
	db 20, POLIWAG
	db 20, SLOWPOKE
	db 20, GRIMER

.Route10Reservoir:
	db 3
	db 20, POLIWAG
	db 20, SLOWPOKE
	db 20, GOLDEEN

.SafariWaters:
	db 4
	db 15, DRATINI
	db 22, PSYDUCK
	db 22, SLOWPOKE
	db 22, GOLDEEN

.EasternRivers:
	db 4
	db 20, KRABBY
	db 20, GOLDEEN
	db 20, SLOWPOKE
	db 25, SEAKING

.WesternCoast:
	db 4
	db 22, TENTACOOL
	db 22, SHELLDER
	db 22, HORSEA
	db 22, KRABBY

.FuchsiaBay:
	db 4
	db 25, GOLDEEN
	db 25, KRABBY
	db 25, HORSEA
	db 28, SEAKING

.SeafoamChannel:
	db 4
	db 28, SHELLDER
	db 28, SEEL
	db 28, HORSEA
	db 28, STARYU

.CinnabarCoast:
	db 4
	db 25, STARYU
	db 25, HORSEA
	db 25, TENTACOOL
	db 28, SEAKING

.IndigoWaters:
	db 4
	db 35, SLOWBRO
	db 35, SEAKING
	db 35, KINGLER
	db 35, SEADRA

.CeruleanCave:
	db 4
	db 50, SLOWBRO
	db 50, SEAKING
	db 50, KINGLER
	db 50, SEADRA
