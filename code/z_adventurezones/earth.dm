/**
Centcom / Earth Stuff
Contents:
	Areas:
		Main Area
		Outside
		Offices
		Lobby
		Lounge
		Garden
		Power Supply

	Turfs: Outside Concrete & Grass
**/

var/global/Z4_ACTIVE = 1 //Used for mob processing purposes

/area/centcom
	name = "Centcom"
	icon_state = "purple"
	requires_power = 0
	sound_environment = 4
	teleport_blocked = 1
	skip_sims = 1
	sims_score = 25
	sound_group = "centcom"
	filler_turf = "/turf/unsimulated/nicegrass/random"

/area/centcom/outside
	name = "Earth"
	icon_state = "nothing_earth"
	force_fullbright = 1

/area/centcom/offices
	name = "NT Offices"
	icon_state = "red"

	azungar/name = "Office of Azungar"
	firebarrage/name = "Office of Firebarrage"
	gannets/name = "Office of Hannah Strawberry"
	sydne66/name = "Office of Throrvardr Finvardrardson"
	darkchis/name = "Office of Walter Poehl"
	dions/name = "Office of Dions"
	spyguy/name = "Office of Leif Badstrand"
	haine/name = "Office of Lia Alliman"
	zewaka/name = "Office of Shitty Bill Jr."
	wire/name = "Office of Wire"
	wonk/name = "Office of Wonk"
	drsingh/name = "Office of DrSingh"
	aphtonites/name = "Office of Aphtonites"
	bubs/name = "Office of bubs"
	mbc/name = "Office of Dotty Spud"
	pope/name = "Office of Popecrunch"
	hokie/name = "Office of Hokie"
	shotgunbill/name = "Office of Shotgunbill"
	hukhukhuk/name = "Office of HukHukHuk"
	burntcornmuffin/name = "Office of BurntCornMuffin"
	grayshift/name = "Office of Grayshift"
	keelin/name = "Office of Keelin"
	freshlemon/name = "Office of Belkis Tekeli"
	nakar/name = "Office of Nakar"
	cirrial/name = "Office of Cirrial"
	kremlin/name = "Office of Kremlin"
	mordent/name = "Office of Mordent"
	tobba/name =  "Office of Tobba"
	readster/name = "Office of Readster"
	somepotato/name = "Office of Somepotato"
	pacra/name = "Office of Pacra"
	atomicthumbs/name = "Office of Atomicthumbs"
	supernorn/name = "Office of Supernorn"
	flourish/name = "Office of Flourish"
	gibbed/name = "Office of Rick"
	edad/name = "Office of Edad"
	souricelle/name = "Office of Souricelle"
	hufflaw/name = "Office of Hufflaw"
	aibm/name = "Office of AngriestIBM"
	infinitemonkeys/name = "Office of Infinite Monkeys"
	cogwerks/name = "Office of Cogwerks"
	azungar/name = "Office of Azungar"
	a69/name = "Office of Dixon Balls"
	hydro/name = "Office of HydroFloric"
	crimes/name = "Office of Warcrimes"
	hazoflabs/name = "Shared Office Space of Gerhazo and Flaborized"
	zamujaza/name = "Office of Zamujasa"
	reginaldhj/name = "Office of ReginaldHJ"
	gerhazo/name = "Office of Casey Spark"
	flaborized/name = "Office of Flaborized"
	questx/name = "Office of Boris Bubbleton"
	simianc/name = "Office of C.U.T.I.E."
	kyle/name = "Office of Kyle"
	patrickstar/name = "Office of Patrick Star"
	sageacrin/name = "Office of Escha Thermic"
	pali/name = "Office of Pali"


/area/centcom/lobby
	name = "NT Offices Lobby"
	icon_state = "blue"

/area/centcom/lounge
	name = "NT Recreational Lounge"
	icon_state = "yellow"

/area/centcom/garden
	name = "NT Business Park"
	icon_state = "orange"

/area/centcom/power
	name = "NT Power Supply"
	icon_state = "green"
	blocked = 1

////////////////////////////

/turf/unsimulated/outdoors
	icon = 'icons/turf/outdoors.dmi'

	snow
		name = "snow"
		New()
			dir = pick(cardinal)
		icon_state = "grass_snow"
	grass
		name = "grass"
		New()
			dir = pick(cardinal)
		icon_state = "grass"
		dense
			name = "dense grass"
			desc = "whoa, this is some dense grass. wow."
			density = 1
			opacity = 1
			color = "#AAAAAA"
	concrete
		name = "concrete"
		icon_state = "concrete"