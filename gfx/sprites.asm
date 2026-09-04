SECTION "NPC Sprites 1", ROMX

ScientistSprite::        INCBIN "gfx/sprites/scientist.2bpp"
WandererSprite::         INCBIN "gfx/sprites/wanderer.2bpp"
RockerSprite::           INCBIN "gfx/sprites/rocker.2bpp"
SwimmerSprite::          INCBIN "gfx/sprites/swimmer.2bpp"
SafariZoneWorkerSprite:: INCBIN "gfx/sprites/safari_zone_worker.2bpp"
GymGuideSprite::         INCBIN "gfx/sprites/gym_guide.2bpp"
GrampsSprite::           INCBIN "gfx/sprites/gramps.2bpp"
ClerkSprite::            INCBIN "gfx/sprites/clerk.2bpp"
FishingGuruSprite::      INCBIN "gfx/sprites/fishing_guru.2bpp"
GrannySprite::           INCBIN "gfx/sprites/granny.2bpp"
NurseSprite::            INCBIN "gfx/sprites/nurse.2bpp"
LinkReceptionistSprite:: INCBIN "gfx/sprites/link_receptionist.2bpp"
SilphPresidentSprite::   INCBIN "gfx/sprites/silph_president.2bpp"
SilphWorkerMSprite::     INCBIN "gfx/sprites/silph_worker_m.2bpp"
WardenSprite::           INCBIN "gfx/sprites/warden.2bpp"
CaptainSprite::          INCBIN "gfx/sprites/captain.2bpp"
FisherSprite::           INCBIN "gfx/sprites/fisher.2bpp"
KogaSprite::             INCBIN "gfx/sprites/koga.2bpp"
GuardSprite::            INCBIN "gfx/sprites/guard.2bpp"
PokeBallSprite::         INCBIN "gfx/sprites/poke_ball.2bpp"
FossilSprite::           INCBIN "gfx/sprites/fossil.2bpp"
BoulderSprite::          INCBIN "gfx/sprites/boulder.2bpp"
PaperSprite::            INCBIN "gfx/sprites/paper.2bpp"
PokedexSprite::          INCBIN "gfx/sprites/pokedex.2bpp"
ClipboardSprite::        INCBIN "gfx/sprites/clipboard.2bpp"
SnorlaxSprite::          INCBIN "gfx/sprites/snorlax.2bpp"
OldAmberSprite::         INCBIN "gfx/sprites/old_amber.2bpp"
GamblerAsleepSprite::    INCBIN "gfx/sprites/gambler_asleep.2bpp"

; Inspired by Viridian School's notebook desk and chair tiles.
GardenTableSprite::
	db $1f, $1f, $2f, $31, $2f, $31, $2b, $35, $2f, $31, $21, $3f, $1f, $1f, $ff, $ff
	db $f8, $f8, $f4, $8c, $f4, $8c, $d4, $ac, $f4, $8c, $84, $fc, $f8, $f8, $ff, $ff
	db $80, $ff, $ff, $80, $ff, $ff, $60, $60, $60, $60, $60, $60, $60, $60, $00, $00
	db $01, $ff, $ff, $01, $ff, $ff, $06, $06, $06, $06, $06, $06, $06, $06, $00, $00

GardenChairSprite::
	db $00, $00, $00, $00, $1f, $1f, $20, $20, $27, $20, $27, $20, $27, $20, $20, $20
	db $00, $00, $00, $00, $fc, $f8, $04, $04, $e4, $04, $e4, $04, $e4, $04, $04, $04
	db $3f, $20, $3f, $2f, $38, $2f, $3d, $2a, $3e, $39, $00, $00, $00, $00, $00, $00
	db $fc, $04, $fc, $f4, $1c, $f4, $7c, $94, $fc, $1c, $00, $00, $00, $00, $00, $00


; A folded dark tunic with a pale R, in the same four-tile format as other props.
RocketUniformSprite::
	db $00, $00, $07, $07, $0d, $0e, $13, $1e, $21, $3f, $20, $3f, $21, $3e, $21, $3e
	db $00, $00, $e0, $e0, $b0, $70, $98, $78, $84, $fc, $04, $fc, $c4, $3c, $44, $bc
	db $21, $3e, $21, $3e, $21, $3e, $3f, $3f, $10, $1f, $1f, $1f, $00, $00, $00, $00
	db $c4, $3c, $44, $bc, $24, $dc, $fc, $fc, $08, $f8, $f8, $f8, $00, $00, $00, $00


SECTION "Whirlpool Sprite", ROMX

INCLUDE "gfx/sprites/whirlpool.asm"

SECTION "NPC Sprites 2", ROMX

RedBikeSprite::          INCBIN "gfx/sprites/red_bike.2bpp"
RedSprite::              INCBIN "gfx/sprites/red.2bpp"
BlueSprite::             INCBIN "gfx/sprites/blue.2bpp"
OakSprite::              INCBIN "gfx/sprites/oak.2bpp"
YoungsterSprite::        INCBIN "gfx/sprites/youngster.2bpp"
MonsterSprite::          INCBIN "gfx/sprites/monster.2bpp"
CooltrainerFSprite::     INCBIN "gfx/sprites/cooltrainer_f.2bpp"
CooltrainerMSprite::     INCBIN "gfx/sprites/cooltrainer_m.2bpp"
LittleGirlSprite::       INCBIN "gfx/sprites/little_girl.2bpp"
BirdSprite::             INCBIN "gfx/sprites/bird.2bpp"
MiddleAgedManSprite::    INCBIN "gfx/sprites/middle_aged_man.2bpp"
GamblerSprite::          INCBIN "gfx/sprites/gambler.2bpp"
SuperNerdSprite::        INCBIN "gfx/sprites/super_nerd.2bpp"
GirlSprite::             INCBIN "gfx/sprites/girl.2bpp"
HikerSprite::            INCBIN "gfx/sprites/hiker.2bpp"
BeautySprite::           INCBIN "gfx/sprites/beauty.2bpp"
GentlemanSprite::        INCBIN "gfx/sprites/gentleman.2bpp"
DaisySprite::            INCBIN "gfx/sprites/daisy.2bpp"
BikerSprite::            INCBIN "gfx/sprites/biker.2bpp"
SailorSprite::           INCBIN "gfx/sprites/sailor.2bpp"
CookSprite::             INCBIN "gfx/sprites/cook.2bpp"
BikeShopClerkSprite::    INCBIN "gfx/sprites/bike_shop_clerk.2bpp"
MrFujiSprite::           INCBIN "gfx/sprites/mr_fuji.2bpp"
GiovanniSprite::         INCBIN "gfx/sprites/giovanni.2bpp"
RocketSprite::           INCBIN "gfx/sprites/rocket.2bpp"
ChannelerSprite::        INCBIN "gfx/sprites/channeler.2bpp"
WaiterSprite::           INCBIN "gfx/sprites/waiter.2bpp"
SilphWorkerFSprite::     INCBIN "gfx/sprites/silph_worker_f.2bpp"
MiddleAgedWomanSprite::  INCBIN "gfx/sprites/middle_aged_woman.2bpp"
BrunetteGirlSprite::     INCBIN "gfx/sprites/brunette_girl.2bpp"
LanceSprite::            INCBIN "gfx/sprites/lance.2bpp"
MomSprite::              INCBIN "gfx/sprites/mom.2bpp"
BaldingGuySprite::       INCBIN "gfx/sprites/balding_guy.2bpp"
LittleBoySprite::        INCBIN "gfx/sprites/little_boy.2bpp"
GameboyKidSprite::       INCBIN "gfx/sprites/gameboy_kid.2bpp"
FairySprite::            INCBIN "gfx/sprites/fairy.2bpp"
AgathaSprite::           INCBIN "gfx/sprites/agatha.2bpp"
BrunoSprite::            INCBIN "gfx/sprites/bruno.2bpp"
LoreleiSprite::          INCBIN "gfx/sprites/lorelei.2bpp"
SeelSprite::             INCBIN "gfx/sprites/seel.2bpp"
