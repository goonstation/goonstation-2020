/datum/plant/artifact
	name = "Unknown"
	special_dmi = 'icons/obj/hydroponics/hydro_alien.dmi'
	cantscan = 1
	vending = 0

// non-harvestables

/datum/plant/artifact/pukeplant
	name = "Puker"
	growthmode = "weed"
	special_icon = "puker"
	unique_seed = /obj/item/seed/alien/pukeplant
	nothirst = 1
	starthealth = 80
	growtime = 60
	harvtime = 140
	harvestable = 0
	endurance = 40
	special_proc = 1

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA.harvtime) && prob(20))
			POT.visible_message("<span style=\"color:red\"><b>[POT.name]</b> vomits profusely!</span>")
			playsound(POT.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			if(!locate(/obj/decal/cleanable/vomit) in POT.loc) make_cleanable( /obj/decal/cleanable/vomit,POT.loc)

/datum/plant/artifact/peeker
	name = "Peeker"
	growthmode = "weed"
	special_icon = "peeker"
	unique_seed = /obj/item/seed/alien/peeker
	nothirst = 1
	starthealth = 120
	growtime = 20
	harvtime = 100
	harvestable = 0
	endurance = 60
	special_proc = 1

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.growtime + DNA.growtime) && prob(16))
			var/list/stuffnearby = list()
			for (var/mob/living/X in view(7,POT)) stuffnearby.Add("[X.name]")
			for (var/obj/item/X in view(7,POT)) stuffnearby.Add("[X.name]")
			if (stuffnearby.len > 1) POT.visible_message("<span style=\"color:red\"><b>[POT.name]</b> stares at [pick(stuffnearby)].</span>")

// harvestables

/datum/plant/artifact/dripper
	name = "Dripper"
	special_icon = "dripper"
	crop = /obj/item/reagent_containers/food/snacks/plant/purplegoop
	unique_seed = /obj/item/seed/alien/dripper
	starthealth = 4
	growtime = 15
	harvtime = 45
	cropsize = 3
	harvests = 6
	endurance = 0
	assoc_reagents = list("plasma")

/datum/plant/artifact/rocks
	name = "Rock"
	special_icon = "rocks"
	crop = /obj/item/raw_material/rock
	unique_seed = /obj/item/seed/alien/rocks
	starthealth = 80
	growtime = 220
	harvtime = 500
	cropsize = 3
	harvests = 8
	endurance = 40
	force_seed_on_harvest = 1
	mutations = list(/datum/plantmutation/rocks/syreline,/datum/plantmutation/rocks/bohrum,/datum/plantmutation/rocks/mauxite,/datum/plantmutation/rocks/erebite)

/datum/plant/artifact/litelotus
	name = "Light Lotus"
	special_icon = "litelotus"
	crop = /obj/item/reagent_containers/food/snacks/plant/glowfruit
	unique_seed = /obj/item/seed/alien/litelotus
	starthealth = 30
	growtime = 280
	harvtime = 300
	cropsize = 2
	harvests = 2
	endurance = 20
	assoc_reagents = list("omnizine")

/datum/plant/artifact/plasma
	name = "Plasma"
	special_icon = "plasma"
	crop = /obj/critter/spore
	unique_seed = /obj/item/seed/alien/plasma
	starthealth = 20
	growtime = 180
	harvtime = 220
	cropsize = 2
	harvests = 1
	endurance = 10

/datum/plant/artifact/goldfish
	name = "Goldfish"
	special_icon = "goldfish"
	crop = /obj/item/reagent_containers/food/snacks/goldfish_cracker
	unique_seed = /obj/item/seed/alien/goldfish
	starthealth = 40
	growtime = 80
	harvtime = 120
	cropsize = 4
	harvests = 6
	endurance = 30

/datum/plant/artifact/cat
	name = "Synthetic Cat"
	special_icon = "cat"
	crop = /obj/critter/cat/synth
	unique_seed = /obj/item/seed/alien/cat
	starthealth = 90 // 9 lives
	growtime = 100
	harvtime = 150
	endurance = 30
	special_proc = 1
	attacked_proc = 1
	harvestable = 0

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.growtime + DNA.growtime) && prob(16))
			playsound(get_turf(POT),'sound/voice/animal/cat.ogg',30,1,-1)
			POT.visible_message("<span style=\"color:red\"><b>[POT.name]</b> meows!</span>")

		if (POT.growth > (P.harvtime + DNA.harvtime + 10))
			var/obj/critter/cat/synth/C = new(POT.loc)
			C.health = POT.health
			POT.visible_message("<span style=\"color:blue\">The synthcat climbs out of the tray!</span>")
			POT.HYPdestroyplant()
			return

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth < (P.growtime + DNA.growtime)) return 0

		playsound(get_turf(POT),'sound/voice/animal/cat_hiss.ogg',30,1,-1)
		POT.visible_message("<span style=\"color:red\"><b>[POT.name]</b> hisses!</span>")

// Weird Shit

/datum/plant/maneater
	name = "Man-Eating"
	sprite = "Maneater"
	growthmode = "carnivore"
	unique_seed = /obj/item/seed/maneater
	starthealth = 40
	growtime = 30
	harvtime = 200
	harvestable = 0
	endurance = 10
	special_proc = 1
	attacked_proc = 1
	vending = 0

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes
		if (POT.growth > (P.growtime + DNA.growtime) && prob(4))
			var/MEspeech = pick("Feed me!", "I'm hungryyyy...", "Give me blood!", "I'm starving!", "What's for dinner?")
			for(var/mob/M in hearers(POT, null)) M.show_message("<B>Man-Eating Plant</B> gurgles, \"[MEspeech]\"")
		if (POT.growth > (P.harvtime + DNA.harvtime))
			var/obj/critter/maneater/ME = new(POT.loc)
			ME.health = POT.health * 3
			ME.friends = ME.friends | POT.contributors
			POT.visible_message("<span style=\"color:blue\">The man-eating plant climbs out of the tray!</span>")
			POT.HYPdestroyplant()
			return

	HYPattacked_proc(var/obj/machinery/plantpot/POT,var/mob/user)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth < (P.growtime + DNA.growtime)) return 0

		var/MEspeech = pick("Hands off, asshole!","The hell d'you think you're doin'?!","You dick!","Bite me, motherfucker!")
		for(var/mob/O in hearers(POT, null))
			O.show_message("<B>Man-Eating Plant</B> gurgles, \"[MEspeech]\"", 1)
		boutput(user, "<span style=\"color:red\">The plant angrily bites you!</span>")
		random_brute_damage(user, 9,1)
		return 1

/datum/plant/crystal
	name = "Crystal"
	starthealth = 50
	growtime = 300
	harvtime = 600
	harvestable = 1
	endurance = 100
	vending = 0
	crop = /obj/item/raw_material/shard/plasmacrystal
