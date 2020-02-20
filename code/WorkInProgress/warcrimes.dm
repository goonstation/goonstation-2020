#define GEHENNA_TIME 1

//aw fuck he's doin it again


/obj/landmark/viscontents_spawn
	name = "visual mirror spawn"
	desc = "Links a pair of corresponding turfs in holy Viscontent Matrimony. You shouldnt be seeing this."
	var/targetZ = 1 // target z-level to push it's contents to
	var/xOffset = 0 // use only for pushing to the same z-level
	var/yOffset = 0 // use only for pushing to the same z-level

	New()
		var/turf/greasedupFrenchman = loc
		greasedupFrenchman.vistarget = locate(src.x + xOffset, src.y + yOffset, src.targetZ)
		greasedupFrenchman.vistarget.warptarget = greasedupFrenchman
		greasedupFrenchman.updateVis()
		qdel(src) // vaccinate your children


/turf/var/turf/vistarget = null	// target turf for projecting its contents elsewhere
/turf/var/turf/warptarget = null // target turf for teleporting its contents elsewhere
/*
/turf/proc/updateVis() // locates all appropriate objects on this turf, and pushes them to the vis_contents of the target
	if(vistarget)
		vistarget.overlays.Cut()
		vistarget.vis_contents = list()
		for(var/atom/A in src.contents)
			if (istype(A, (/obj/overlay)))
				continue
			if (istype(A, (/mob/dead)))
				continue
			if (istype(A, (/mob/living/intangible)))
				continue
			vistarget.vis_contents += A
*/
/turf/proc/updateVis()
	if(vistarget)
		vistarget.overlays.Cut()
		vistarget.vis_contents = src

// No mor vis shit
// Gehenna shit tho
/turf/gehenna
	name = "planet gehenna"
	desc = "errrr"

/turf/gehenna/desert
	name = "barren wasteland"
	desc = "Looks really dry out there."
	icon = 'icons/turf/floors.dmi'
	icon_state = "gehenna"
	carbon_dioxide = 10*(sin(GEHENNA_TIME + 3)+ 1)
	oxygen = MOLES_O2STANDARD
	//temperature = WASTELAND_MIN_TEMP + (0.5*sin(GEHENNA_TIME)+1)*(WASTELAND_MAX_TEMP - WASTELAND_MIN_TEMP)
	luminosity = 0.5*(sin(GEHENNA_TIME)+ 1)

	var/datum/light/point/light = null
	var/light_r = 0.5*(sin(GEHENNA_TIME)+1)
	var/light_g = 0.3*(sin(GEHENNA_TIME )+1)
	var/light_b = 0.3*(sin(GEHENNA_TIME + 3 )+1)
	var/light_brightness = 0.4*(sin(GEHENNA_TIME)+1)
	var/light_height = 3
	var/generateLight = 1

	New()
		..()
		if (generateLight)
			src.make_light() /*
			generateLight = 0
			if (z != 3) //nono z3
				for (var/dir in alldirs)
					var/turf/T = get_step(src,dir)
					if (istype(T, /turf/simulated))
						generateLight = 1
						src.make_light()
						break */


	make_light()
		if (!light)
			light = new
			light.attach(src)
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.set_height(light_height)
		light.enable()



	plating
		name = "sand-covered plating"
		desc = "The desert slowly creeps upon everything we build."
		icon = 'icons/turf/floors.dmi'
		icon_state = "plating_dusty3"

	path
		name = "beaten earth"
		desc = "for seven years we toiled, to tame wild Gehenna"
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_edge"

	corner
		name = "beaten earth"
		desc = "for seven years we toiled, to tame wild Gehenna"
		icon = 'icons/turf/floors.dmi'
		icon_state = "gehenna_corner"


/area/gehenna

/area/gehenna/wasteland
	icon_state = "red"
	name = "the barren wastes"
	teleport_blocked = 1

// regular stuff below

/area/diner/tug
	icon_state = "green"
	name = "Big Yank's Cheap Tug"

/area/shuttle/john/diner
	icon_state = "shuttle"

/area/shuttle/john/owlery
	icon_state = "shuttle2"

/area/shuttle/john/mining
	icon_state = "shuttle2"

/obj/item/clothing/head/paper_hat/john
	name = "John Bill's paper bus captain hat"
	desc = "This is made from someone's tax returns"

/obj/item/clothing/mask/cigarette/john
	name = "John Bill's cigarette"
	on = 1
	put_out(var/mob/user as mob, var/message as text)
		// how about we do literally nothing instead?

/obj/item/clothing/shoes/thong
	name = "garbage flip-flops"
	desc = "These cheap sandals don't even look legal."
	icon_state = "thong"
	protective_temperature = 0
	permeability_coefficient = 1
	var/possible_names = list("sandals", "flip-flops", "thongs", "rubber slippers", "jandals", "slops", "chanclas")
	var/stapled = FALSE

	New()
		..()
		if (!(src in processing_items))
			processing_items.Add(src)

	pooled()
		if ((src in processing_items))
			processing_items.Remove(src)
		..()

	unpooled()
		..()
		if (!(src in processing_items))
			processing_items.Add(src)

	process()
		if (stapled && (src in processing_items))
			processing_items.Remove(src)
			src.desc = "Two thongs stapled together, to make a MEGA VELOCITY boomarang."
		else
			src.desc = "These cheap [pick(possible_names)] don't even look legal."

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/staple_gun) && !stapled)
			stapled = TRUE
			boutput(user, "You staple the [src] together to create a mighty thongarang.")
			name = "thongarang"
			icon_state = "thongarang"
			throwforce = 5
			throw_range = 10
			throw_return = 1
		else
			..()

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("heatprot", 0)
		setProperty("conductivity", 1)


var/list/JOHN_greetings = strings("johnbill.txt", "greetings")
var/list/JOHN_rude = strings("johnbill.txt", "rude")
var/list/JOHN_insults = strings("johnbill.txt", "insults")
var/list/JOHN_people = strings("johnbill.txt", "people")
var/list/JOHN_question = strings("johnbill.txt", "question")
var/list/JOHN_item = strings("johnbill.txt", "item")
var/list/JOHN_drugs = strings("johnbill.txt", "drugs")
var/list/JOHN_nouns = strings("johnbill.txt", "nouns")
var/list/JOHN_verbs = strings("johnbill.txt", "verbs")
var/list/JOHN_stories = strings("johnbill.txt", "stories1") + strings("johnbill.txt", "stories2") + strings("johnbill.txt", "stories3")
var/list/JOHN_doMiss = strings("johnbill.txt", "domiss")
var/list/JOHN_dontMiss = strings("johnbill.txt", "dontmiss")
var/list/JOHN_friends = strings("johnbill.txt", "friends")
var/list/JOHN_friendActions = strings("johnbill.txt", "friendsactions")
var/list/JOHN_emotes = strings("johnbill.txt", "emotes")
var/list/JOHN_deadguy = strings("johnbill.txt", "deadguy")
var/list/JOHN_murray = strings("johnbill.txt", "murraycompliment")
var/list/JOHN_grilladvice = strings("johnbill.txt", "grilladvice")


// all of john's area specific lines here
area/var/john_talk = null
area/owlery/owleryhall/john_talk = list("Oh dang, That's me! Wait... Oh dang guys, I think I'm banned from here.","Hope these guys don't mind I stole their bus.","Oh i've seen a scanner like that before. Lotta radiation.","Hey that thing there? Looks important.")
area/owlery/owleryhall/gangzone/john_talk = list("I don't likesa the looksa these Italians, brud","That's some tough lookin boids- We cool?","Oughta grill a couple of these types. Grill em well done.")
area/diner/dining/john_talk = list("This place smells a lot like my bro.","This was a good spot to park the bus.","Y'all got a grill in here?","Could do a lot of crimes back there. Probably will.")
area/diner/bathroom/john_talk = list("I haven't been here in a foggy second!", "I wonder what the fungus on the walls here tastes like... wanna juice it?", "I always wondered what happened to this toilet.")
area/lower_arctic/lower/john_talk = list("I ain't a fan of wendibros, they steal my meat.","Chilly eh?")
area/moon/museum/west/john_talk = list("Got lost here once. More than once. Every time.","You got a map, beardo?","Can we go home yet?")
area/jones/bar/john_talk = list("When the heck am I gonna get some service here, I'm parched!","What do I gotta start purrin' to get a drink here?","What's the holdup, catscratch? Let's get this party started!")
area/solarium/john_talk = list("You kids will try anything, wontcha?","Nice sun, dorkus.","So it's a star? Big deal.","I betcha my bus coulda got us here faster, dork.","All righty, now let's grill a steak on that thing!","You bring any snacks?")
area/marsoutpost/john_talk= list("Things weren't this dry last time I was here.","Really let the place go to the rats didn't they.","Great place for a cookout, if you ask me.")
area/marsoutpost/duststorm/john_talk= list("Aw fuck, I've seen storms like this before. Where the hell was that planet...","Gehenna awaits.")
area/sim/racing_entry/john_talk = list("Haha I'm a Nintendo","Beep Boop","Lookit Ma'! I'm in the computer!","Ey cheggit out! Pixels!")
area/crypt/sigma/mainhall/john_talk = list("Looks a heck a spooky in here","Wonder if there's any meat in that swamp?")
area/iomoon/base/john_talk = list("Yknow, I think it's almost too hot to grill out there.","This place is a lot shittier than Mars, y'know that?","I didn't really wanna come along you know. I did this for you.")
area/dojo/john_talk = list("Eyyy, just like my cartoons!","What a sight! Gotta admire the Italians, eh?")
area/dojo/sakura/john_talk = list("Shoshun mazu, Sake ni ume uru, Nioi kana","Haru moya ya, Keshiki totonou, Tsuki to ume","Hana no kumo, Kane ha Ueno ka, Asakusa ka")
area/meat_derelict/entry/john_talk = list("Oooh baby now we're talkin! Now we're talkin!","Oh heck yeah now that's my kind of adventure, eh?","Oh boy do I have a good feelin' about this one!")
area/meat_derelict/main/john_talk = list("Aw yeah dog, this place just gets better and better!","Mmm Mmm! That smells fresh and ready for a grillin'!")
area/meat_derelict/guts/john_talk = list("And just when I thought it couldnt get better.","Pinch me, I'm dreaming!","Smells good in here, like vinegar!")
area/meat_derelict/boss/john_talk = list("I'm gonna need a bigger grill.","Fuck that's a big steak!","Oooh mama we are cooked now!")
area/meat_derelict/soviet/john_talk = list("Betcha these rooskies don't even own a grill","Wonder what these reds are doin in my steak palace?","Ah, gotta debone that before ya cook it.")
area/bee_trader/john_talk = list("That little Bee, always gettin' inta trouble.","Hey remember that weird puzzle with the showerheads?","What a nasty museum that was, eh? Nasty.")
area/flock_trader/john_talk = list("Woah, what's with these teal chickens? Must be good grillin'.","I feel like this was revealed to me in a fever dream once.","Dang, that's a mighty fine chair.")
area/timewarp/ship/john_talk = list("I wonder if my ol' compadre Murray is around.","Did ya see those clocks outside? Time just flies by.","I swear I saw a ship just like this years ago, but somewhere else.","Didn't they use to haul some strange stuff on these gals?")
area/derelict_ai_sat/core/john_talk = list("Hello, Daddy.","You should probably start writing down the shit I say, I certainly can't remember any of it.")
area/adventure/urs_dungeon/john_talk = list("This place smells like my bro.","Huh, Always wondered what those goggles did.","Huh, Always wondered what those goggles did.","Your hubris will be punished. Will you kill your fellow man to save yourself? Who harvests the harvestmen? What did it feel like when you lost your mind?")

// bus driver
/mob/living/carbon/human/john
	real_name = "John Bill"
	interesting = "Found in a coffee can at age fifteen. Went to jail for fraud. Recently returned to the can."
	gender = MALE
	var/talk_prob = 7
	var/greeted_murray = 0
	var/list/snacks = null
	var/gotsmokes = 0

	New()
		..()
		johnbills += src
		SPAWN_DBG(0)
			bioHolder.mobAppearance.customization_first = "Tramp"
			bioHolder.mobAppearance.customization_first_color = "#281400"
			bioHolder.mobAppearance.customization_second = "Pompadour"
			bioHolder.mobAppearance.customization_second_color = "#241200"
			bioHolder.mobAppearance.customization_third = "Tramp: Beard Stains"
			bioHolder.mobAppearance.customization_third_color = "#663300"
			bioHolder.age = 63
			bioHolder.bloodType = "A+"
			bioHolder.mobAppearance.gender = "male"
			bioHolder.mobAppearance.underwear = "briefs"
			bioHolder.mobAppearance.u_color = "#996633"

			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			src.equip_if_possible(new /obj/item/clothing/shoes/thong(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/color/orange(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/mask/cigarette/john(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/head/paper_hat/john(src), slot_head)

			var/obj/item/implant/access/infinite/shittybill/implant = new /obj/item/implant/access/infinite/shittybill(src)
			implant.implanted(src, src)

	disposing()
		johnbills -= src
		..()

	// John Bill always goes to the afterlife bar.
	death(gibbed)
		..(gibbed)

		johnbills.Remove(src)

		if (!src.client)
			var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

			var/mob/living/carbon/human/john/newbody = new()
			newbody.set_loc(target_turf)
			newbody.overlays += image('icons/misc/32x64.dmi',"halo")
			if(inafterlifebar(src))
				qdel(src)
			return
		else
			boutput(src, "<span style='font-size: 1.5em; color: blue;'><B>Haha you died loser.</B></span>")
			src.become_ghost()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if(!src.stat && !src.client)
			if(target)
				if(isdead(target))
					target = null
				if(get_dist(src, target) > 1)
					step_to(src, target, 1)
				if(get_dist(src, target) <= 1 && !LinkBlocked(src.loc, target.loc))
					var/obj/item/W = src.equipped()
					if (!src.restrained())
						if(W)
							W.attack(target, src, ran_zone("chest"))
						else
							target.attack_hand(src)
			else if(ai_aggressive)
				a_intent = INTENT_HARM
				for(var/mob/M in oview(5, src))
					if(M == src)
						continue
					if(M.type == src.type)
						continue
					if(M.stat)
						continue
					// stop on first human mob
					if(ishuman(M))
						target = M
						break
					target = M
			if(prob(20) && src.canmove && isturf(src.loc))
				step(src, pick(NORTH, SOUTH, EAST, WEST))
			if(prob(2))
				SPAWN_DBG(0) emote(pick(JOHN_emotes))
			if(prob(15))
				snacktime()
			if(prob(talk_prob))
				src.speak()

	proc/snacktime()
		snacks = list()
		for(var/obj/item/reagent_containers/food/snacks/S in src)
			snacks += S
		if(snacks.len > 0)
			var/obj/item/reagent_containers/food/snacks/snacc = pick(snacks)
			if(istype(snacc, /obj/item/reagent_containers/food/snacks/bite))
				if(prob(75))
					return
				else
					src.visible_message("<span style=\"color:red\">[src] horks up a lump from his stomach... </span>")
			snacc.Eat(src,src,1)


	proc/speak()
		SPAWN_DBG(0)
			var/list/grills = list()

			var/obj/machinery/bot/guardbot/old/tourguide/murray = pick(tourguides)
			if (murray && get_dist(src,murray) > 7)
				murray = null
			if (istype(murray))
				if (!findtext(murray.name, "murray"))
					murray = null

			var/area/A = get_area(src)
			var/list/alive_mobs = list()
			var/list/dead_mobs = list()
			if (A.population && A.population.len)
				for(var/mob/living/M in oview(5,src))
					if(!isdead(M))
						alive_mobs += M
					else
						dead_mobs += M

			if (prob(20))
				for(var/obj/machinery/shitty_grill/G in orange(5, src))
					grills.Add(G)

			if (prob(50) && A.john_talk)
				say(pick(get_area(src).john_talk))
				get_area(src).john_talk = null

			else if (grills.len > 0)
				var/obj/machinery/shitty_grill/G = pick(grills)
				if (G.grillitem)
					switch(G.cooktime)
						if (0 to 15)
							say("Yep, \the [G.grillitem] needs a little more time.")
						if (16 to 49)
							say("[pick(JOHN_rude)], [pick(JOHN_grilladvice)] [G.grillitem].")
						if (50 to 59)
							say("Whoa! \The [G.grillitem] is cooked to perfection! Lemme get that for ya!")
							G.eject_food()
						else
							say("Good fuckin' job [pick(JOHN_insults)], you burnt it.")
				else
					if (G.grilltemp >= 200 + T0C)
						if(prob(70))
							say("That there ol' [G] looks about ready for a [pick(JOHN_drugs)]-seasoned steak!")
						else
							say("That [G] is hot! Who's grillin' ?")
					else
						say("Anyone gonna fire up \the [G]?")

			else if(prob(40) && dead_mobs && dead_mobs.len > 0) //SpyGuy for undefined var/len (what the heck)
				var/mob/M = pick(dead_mobs)
				say("[pick(JOHN_deadguy)] [M.name]...")
			else if (alive_mobs.len > 0)
				if (murray && !greeted_murray)
					greeted_murray = 1
					say("[pick(JOHN_greetings)] Murray! How's it [pick(JOHN_verbs)]?")
					SPAWN_DBG(rand(20,40))
						if (murray && murray.on && !murray.idle)
							murray.speak("Hi, John! It's [pick(JOHN_murray)] to see you here, of all places.")

				else
					var/mob/M = pick(alive_mobs)
					var/speech_type = rand(1,11)

					switch(speech_type)
						if(1)
							say("[pick(JOHN_greetings)] [M.name].")

						if(2)
							say("[pick(JOHN_question)] you lookin' at, [pick(JOHN_insults)]?")

						if(3)
							say("You a [pick(JOHN_people)]?")

						if(4)
							say("[pick(JOHN_rude)], gimme yer [pick(JOHN_item)].")

						if(5)
							say("Got a light, [pick(JOHN_insults)]?")

						if(6)
							say("Nice [pick(JOHN_nouns)], [pick(JOHN_insults)].")

						if(7)
							say("Got any [pick(JOHN_drugs)]?")

						if(8)
							say("I ever tell you 'bout [pick(JOHN_stories)]?")

						if(9)
							say("You [pick(JOHN_verbs)]?")

						if(10)
							if (prob(50))
								say("Man, I sure miss [pick(JOHN_doMiss)].")
							else
								say("Man, I sure don't miss [pick(JOHN_dontMiss)].")

						if(11)
							say("I think my [pick(JOHN_friends)] [pick(JOHN_friendActions)].")

					if (prob(25) && shittybills.len > 0)
						SPAWN_DBG(3.5 SECONDS)
							var/mob/living/carbon/human/biker/MB = pick(shittybills)
							switch (speech_type)
								if (4)
									MB.say("You borrowed mine fifty years ago, and I never got it back.")
								if (7)
									MB.say("If I had any, I wouldn't share it with ya [pick(BILL_insults)].")
								if (8)
									if (prob(2))
										MB.say("One of these days, you oughta. I don't believe it for a second but let's hear it, [pick(BILL_people)].")
									else if (prob(6))
										MB.say("No way, [src].")
									else
										MB.say("Yeah, [src], you told me that one before.")
								if (9)
									if (prob(50))
										MB.say("Yeah, sometimes.")
									else
										MB.say("No way.")
								else
									MB.speak()



	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			boutput(M, "<span style=\"color:blue\"><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("One of them [pick(JOHN_people)] folks from the station helped us raise the cash. Lil bro been dreamin bout it fer years.")
			return
		if (istype(W, /obj/item/reagent_containers/food/snacks) || (istype(W, /obj/item/clothing/mask/cigarette/cigarillo) && !gotsmokes))
			boutput(M, "<span style=\"color:blue\"><b>You offer [W] to [src]</b> </span>")
			M.u_equip(W)
			W.set_loc(src)
			W.dropped()
			src.drop_item()
			src.put_in_hand_or_drop(W)

			SPAWN_DBG(1 DECI SECOND)
				say("Oh? [W] eh?")
				say(pick("No kiddin' fer me?","I guess I could go fer a quick one yeah!","Oh dang dang dang! Haven't had one of these babies in a while!","Well I never get tired of those!","You're offering this to me? Don't mind if i do, [pick(JOHN_people)]"))
				src.a_intent = INTENT_HELP // pacify a juicer with food, obviously
				src.target = null
				src.ai_state = 0
				src.ai_target = null

				if (istype(W, /obj/item/clothing/mask/cigarette/cigarillo/juicer))
					gotsmokes = 1
					sleep(30)
					say(pick("Listen bud, I don't know who sold you these, but they ain't your pal.","Y'know these ain't legal in any NT facilities, right?","Maybe you ain't so dumb as ya look, brud."))
					var/obj/item/clothing/mask/cigarette/cigarillo/juicer/J = W
					src.u_equip(wear_mask)
					src.equip_if_possible(J, slot_wear_mask)
					J.cant_other_remove = 0
					sleep(30)
					J.light(src, "<span style='color:red'><b>[src]</b> casually lights [J] and takes a long draw.</span>")
					sleep(50)
#if BUILD_TIME_DAY >= 28 // this block controls whether or not it is the right time to smoke a fat doink with Big J
					say("You know a little more than you let on, don't you?")
					sleep(70)
					say("See but I been away long enough that I don't know much about you.")
					emote("cough")
					sleep(150)
					particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(src.loc, src.dir))
					say("Other than you 'trasies really did me and my bro a solid, back when there was that whole business with the bee n' all that. A real solid. But by now you're wonderin' why we were involved with her anyhow.")
					sleep(70)
					say("All in due time.")
					emote("cough")
					sleep(90)
					J.put_out(src, "<b>[src]</b> distractedly drops and treads on the lit [J.name], putting it out instantly.")
					src.u_equip(J)
					J.set_loc(src.loc)
					sleep(20)
					say("These just don't taste the same without him...")
#else // it is not time
					say(pick("This ain't the time, but we should have a talk. A long talk.","Under better circumstances, I'd like to smoke a few of these and reminesce with ya.","We'll have to do this again some time. When the time is right."))
#endif
					gotsmokes = 0

				else if(istype(W, /obj/item/clothing/mask/cigarette))
					say(pick("Well this ain't my usual brand, but...", "Oh actually, got any... uh nah you've probably never even seen one of those.","Wait a second, this ain't a real 'Rillo."))
					var/obj/item/clothing/mask/cigarette/cig = W
					src.u_equip(wear_mask)
					src.equip_if_possible(cig, slot_wear_mask)
					sleep(30)
					cig.light(src, "<span style='color:red'><b>[src]</b> cautiously lights [cig] and takes a short draw.</span>")
					sleep(50)
					say(pick("Yeah that's ol' Dan's stuff...","But hey, thanks for the smokes, bruddo.","Smooth. Too smooth."))
			return
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0)
		if (special) //vamp or ling
			src.target = M
			src.ai_state = 2
			src.ai_threatened = world.timeofday
			src.ai_target = M
			src.a_intent = INTENT_HARM
			src.ai_active = 1

		for (var/mob/SB in shittybills)
			var/mob/living/carbon/human/biker/S = SB
			if (get_dist(S,src) <= 7)
				if(!(S.ai_active) || (prob(25)))
					S.say("That's my brother, you [pick(JOHN_insults)]!")
				S.target = M
				S.ai_active = 1
				S.a_intent = INTENT_HARM




var/bombini_saved = 0

/obj/machinery/computer/shuttle_bus
	name = "John's Bus"
	icon_state = "shuttle"


/obj/machinery/computer/shuttle_bus/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.


	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25




/obj/machinery/computer/shuttle_bus/attack_hand(mob/user as mob)
	if(..())
		return
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a><BR><BR>"

	switch(johnbus_location)
		if(0)
			dat += "Shuttle Location: Diner"
		if(1)
			dat += "Shuttle Location: Frontier Space Owlery"
		if(2)
			dat += "Shuttle Location: Old Mining Station"


	dat += "<BR>"
	switch(johnbus_destination)
		if(0)
			dat += "Shuttle Destination: Diner"
		if(1)
			dat += "Shuttle Destination: Frontier Space Owlery"
		if(2)
			dat += "Shuttle Destination: Old Mining Station"

	dat += "<BR><BR>"
	if(johnbus_active)
		dat += "Satus: Cruisin"
	else
		dat += "<a href='byond://?src=\ref[src];dine=1'>Set Target: Diner</a><BR>"
		dat += "<a href='byond://?src=\ref[src];owle=1'>Set Target: Owlery</a><BR>"
#ifndef UNDERWATER_MAP
		dat += "<a href='byond://?src=\ref[src];mine=1'>Set Target: Old Mining Station</a><BR>"
#endif
		dat += "<BR>"
		if (johnbus_location != johnbus_destination)
			dat += "<a href='byond://?src=\ref[src];send=1'>Send It</a><BR><BR>"
		else
			dat += "Let's go somewhere else, ok?<BR>"

	user.Browse(dat, "window=shuttle")
	onclose(user, "shuttle")
	return

/obj/machinery/computer/shuttle_bus/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		usr.machine = src

		if (href_list["send"])
			if(!johnbus_active)
				var/turf/T = get_turf(src)
				johnbus_active = 1
				for(var/obj/machinery/computer/shuttle_bus/C in machines)

					C.visible_message("<span style=\"color:red\">John is starting up the engines, this could take a minute!</span>")

				for(var/obj/machinery/computer/shuttle_bus/embedded/B in machines)
					T = get_turf(B)
					SPAWN_DBG(1 DECI SECOND)
						playsound(T, "sound/effects/ship_charge.ogg", 60, 1)
						sleep(30)
						playsound(T, "sound/machines/weaponoverload.ogg", 60, 1)
						src.visible_message("<span style=\"color:red\">The shuttle is making a hell of a racket!</span>")
						sleep(50)
						playsound(T, "sound/impact_sounds/Machinery_Break_1.ogg", 60, 1)
						for(var/mob/living/M in range(src.loc, 10))
							shake_camera(M, 5, 2)

						sleep(20)
						playsound(T, "sound/effects/creaking_metal2.ogg", 70, 1)
						sleep(30)
						src.visible_message("<span style=\"color:red\">The shuttle engine alarms start blaring!</span>")
						playsound(T, "sound/machines/pod_alarm.ogg", 60, 1)
						var/obj/decal/fakeobjects/shuttleengine/smokyEngine = locate() in get_area(src)
						var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
						smoke.set_up(5, 0, smokyEngine)
						smoke.start()
						sleep(40)
						playsound(T, "sound/machines/boost.ogg", 60, 1)
						for(var/mob/living/M in range(src.loc, 10))
							shake_camera(M, 10, 4)

				T = get_turf(src)
				SPAWN_DBG(25 SECONDS)
					playsound(T, "sound/effects/flameswoosh.ogg", 70, 1)
					call_shuttle()

		else if (href_list["dine"])
			if(!johnbus_active)
				johnbus_destination = 0
				var/turf/T = get_turf(src)
				playsound(T, "sound/machines/glitch1.ogg", 60, 1)

		else if (href_list["owle"])
			if(!johnbus_active)
				johnbus_destination = 1
				var/turf/T = get_turf(src)
				playsound(T, "sound/machines/glitch1.ogg", 60, 1)

		else if (href_list["mine"])
			if(!johnbus_active)
				johnbus_destination = 2
				var/turf/T = get_turf(src)
				playsound(T, "sound/machines/glitch1.ogg", 60, 1)


		else if (href_list["close"])
			usr.machine = null
			usr.Browse(null, "window=shuttle")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/shuttle_bus/proc/call_shuttle()
	var/area/end_location = null
	var/area/start_location = null

	switch(johnbus_destination)
		if(0)
			end_location = locate(/area/shuttle/john/diner)
		if(1)
			end_location = locate(/area/shuttle/john/owlery)
		if(2)
			end_location = locate(/area/shuttle/john/mining)

	switch(johnbus_location)
		if(0)
			start_location = locate(/area/shuttle/john/diner)
			start_location.move_contents_to(end_location)

		if(1)
			start_location = locate(/area/shuttle/john/owlery)

			if(!bombini_saved)
				for(var/obj/npc/trader/bee/b in start_location)
					bombini_saved = 1
					for(var/mob/M in start_location)
						boutput(M, "<span style=\"color:blue\">It would be great if things worked that way, but they don't. You'll need to find what <b>Bombini</b> is missing, now.</span>")

			start_location.move_contents_to(end_location)

		if(2)
			start_location = locate(/area/shuttle/john/mining)
			start_location.move_contents_to(end_location)

	johnbus_location = johnbus_destination

	johnbus_active = 0

	for(var/obj/machinery/computer/shuttle_bus/C in machines)

		C.visible_message("<span style=\"color:red\">John's Juicin' Bus has Moved!</span>")

	return

obj/decal/fakeobjects/thrust
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	name = "ionized exhaust"
	desc = "Thankfully harmless, to registered employees anyway."

obj/decal/fakeobjects/thrust/flames
	icon_state = "engineshit"
obj/decal/fakeobjects/thrust/flames2
	icon_state = "engineshit2"

obj/item/paper/tug/invoice
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale."
	info = {"<b>Client:</b> Bill, John
			<br><b>Date:</b> TBD
			<br><b>Articles:</b> Structure, Static. Pressurized. Single.
			<br><b>Destination:</b> \"where there's rocks at\"\[sic\]
			<br>
			<br><b>Total Charge:</b> 17,440 paid in full with value-added meat.
			<br>Big Yank's Cheap Tug"}

obj/item/paper/tug/warehouse
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale. It is blank"
	info = {"<b>Client:</b>
			<br><b>Date:</b>
			<br><b>Articles:</b>
			<br><b>Duration:</b>
			<br>
			<br><b>Total Charge:</b>
			<br>Big Yank's Stash N Dash"}


/turf/simulated/wall/r_wall/afterbar
	name = "wall"
	desc = null
	attackby(obj/item/W as obj, mob/user as mob, params)
		return


/*
Urs' Hauntdog critter
*/
/obj/critter/hauntdog
	name = "hauntdog"
	desc = "A very, <i>very</i> haunted hotdog. Hopping around. Hopdog."
	icon = 'icons/misc/hauntdog.dmi'
	icon_state = "hauntdog"
	health = 30
	density = 0

	patrol_step()
		if (!mobile)
			return
		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)

		if(isturf(moveto) && !moveto.density)
			flick("hauntdog-hop",src)
			step_towards(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"

	ai_think()
		if(prob(5))
			flip()
		..()

	proc/flip()
		src.visible_message("<b>[src]</b> does a flip!",2)
		flick("hauntdog-flip",src)
		sleep(13)

	CritterDeath()
		if (!src.alive) return
		src.visible_message("<b>[src]</b> stops moving.",2)
		var/obj/item/reagent_containers/food/snacks/hotdog/H = new /obj/item/reagent_containers/food/snacks/hotdog(get_turf(src))

		H.bun = 5
		H.desc = "A very haunted hotdog. A hauntdog, perhaps."
		H.heal_amt += 1
		H.name = "ordinary hauntdog"
		H.food_effects = list("food_all","food_brute")
		if (H.reagents)
			H.reagents.add_reagent("ectoplasm", 10)
		H.update_icon()

		qdel(src)

#ifdef XMAS

/area/station2
	do_not_irradiate = 0
	sound_fx_1 = 'sound/ambience/station/Station_VocalNoise1.ogg'
	var/initial_structure_value = 0
#ifdef MOVING_SUB_MAP
	filler_turf = "/turf/space/fluid/manta"

	New()
		..()
		initial_structure_value = calculate_structure_value()
#else
	filler_turf = null

	New()
		..()
		initial_structure_value = calculate_structure_value()
#endif

/area/station2/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	sound_environment = 10
	workplace = 1
	do_not_irradiate = 1

/area/station2/atmos/hookups
	sound_environment = 3

/area/station2/atmos/hookups/east
	name = "East Air Hookups"

/area/station2/atmos/hookups/west
	name = "West Air Hookups"

/area/station2/atmos/hookups/north
	name = "North Air Hookups"

/area/station2/atmos/hookups/south
	name = "South Air Hookups"

area/station/communications
	name = "Communications Office"
	icon_state = "communicationsoffice"
	sound_environment = 4

	communicationsbedroom
		name = "Communications Office Bedroom"
		icon_state = "communicationsoffice-bedroom"

/area/station2/maintenance/
	name = "Maintenance"
	icon_state = "maintcentral"
	sound_environment = 12
	workplace = 1
	do_not_irradiate = 1

/area/station2/maintenance/NWmaint
	name = "North West Maintenance"
	icon_state = "NWmaint"

/area/station2/maintenance/NEmaint
	name = "North East Maintenance"
	icon_state = "NEmaint"

/area/station2/maintenance/SEmaint
	name = "South East Maintenance"
	icon_state = "SEmaint"

/area/station2/maintenance/SWmaint
	name = "South West Maintenance"
	icon_state = "SWmaint"

/area/station2/maintenance/maintcentral
	name = "Central Maintenance"
	icon_state = "maintcentral"

/area/station2/maintenance/north
	name = "North Maintenance"
	icon_state = "Nmaint"

/area/station2/maintenance/east
	name = "East Maintenance"
	icon_state = "Emaint"

/area/station2/maintenance/west
	name = "West Maintenance"
	icon_state = "Wmaint"

/area/station2/maintenance/south
	name = "South Maintenance"
	icon_state = "Smaint"

/area/station2/maintenance/eastsolar
	name = "East Solar Maintenance"
	icon_state = "SolarcontrolE"

/area/station2/maintenance/westsolar
	name = "West Solar Maintenance"
	icon_state = "SolarcontrolW"

/area/station2/maintenance/southsolar
	name = "South Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/station2/maintenance/northsolar
	name = "North Solar Maintenance"
	icon_state = "SolarcontrolN"

/area/station2/maintenance/inner
	name = "Inner Maintenance"
	icon_state = "imaint"

/area/station2/maintenance/storage
	name = "Atmospherics"
	icon_state = "green"

/area/station2/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/station2/maintenance/lowerstarboard
	name = "Lower Starboard Maintenance"
	icon_state = "lower_starboard_maintenance"

/area/station2/maintenance/lowerport
	name = "Lower Port Maintenance"
	icon_state = "lower_port_maintenance"

/area/station2/maintenance/upperport
	name = "Upper Port Maintenance"
	icon_state = "upper_port_maintenance"

/area/station2/maintenance/upperstarboard
	name = "Upper Starboard Maintenance"
	icon_state = "upper_starboard_maintenance"

/area/station2/hallway/
	name = "Hallway"
	icon_state = "hallC"
	sound_environment = 10

/area/station2/hallway/primary/north
	name = "North Primary Hallway"
	icon_state = "hallN"

/area/station2/hallway/primary/east
	name = "East Primary Hallway"
	icon_state = "hallE"

/area/station2/hallway/primary/south
	name = "South Primary Hallway"
	icon_state = "hallS"

/area/station2/hallway/primary/west
	name = "West Primary Hallway"
	icon_state = "hallW"

/area/station2/hallway/primary/central
	name = "Central Primary Hallway"
	icon_state = "hallC"

/area/station2/hallway/secondary/exit
	name = "Escape Shuttle Hallway"
	icon_state = "escape"

/area/station2/hallway/secondary/north
	name = "North Secondary Hallway"
	icon_state = "hallN2"

/area/station2/hallway/secondary/east
	name = "East Secondary Hallway"
	icon_state = "hallE2"

/area/station2/hallway/secondary/south
	name = "South Secondary Hallway"
	icon_state = "hallS2"

/area/station2/hallway/secondary/west
	name = "West Secondary Hallway"
	icon_state = "hallW2"

/area/station2/hallway/secondary/central
	name = "Central Secondary Hallway"
	icon_state = "hallC2"

area/station/hallway/starboardlowerhallway
	name = "Starboard Lower Hallway"
	icon_state ="starboard_lower_hallway"

area/station/hallway/portlowerhallway
	name = "Port Lower Hallway"
	icon_state ="port_lower_hallway"

area/station/hallway/centralhallway
	name = "Central Hallway"
	icon_state ="central_hallway"

area/station/hallway/portupperhallway
	name = "Port Upper Hallway"
	icon_state ="port_upper_hallway"
	requires_power = 1

area/station/hallway/starboardupperhallway
	name = "Starboard Upper Hallway"
	icon_state ="starboard_upper_hallway"
	requires_power = 1

/area/station2/hallway/secondary/construction
	name = "Construction Area"
	icon_state = "construction"
	workplace = 1
	do_not_irradiate = 1

/area/station2/hallway/secondary/construction2
	name = "Secondary Construction Area"
	icon_state = "construction"
	workplace = 1
	do_not_irradiate = 1

/area/station2/hallway/secondary/entry
	name = "Main Hallway"
	icon_state = "entry"

/area/station2/hallway/secondary/shuttle
	name = "Shuttle Bay"
	icon_state = "shuttle3"

/area/station2/mailroom
	name = "Mailroom"
	icon_state = "mail"
	sound_environment = 2
	workplace = 1

/area/station2/mining
	name = "Mining"
	icon_state = "mining"
	sound_environment = 10

/area/station2/mining/refinery
	name = "Mining Refinery"
	icon_state = "miningg"

/area/station2/mining/magnet
	name = "Mining Magnet Control Room"
	icon_state = "miningp"

/area/station2/bridge
	name = "Bridge"
	icon_state = "bridge"
	sound_environment = 4
#ifdef SUBMARINE_MAP
	sound_group = "bridge"
	sound_loop = 'sound/ambience/station/underwater/sub_bridge_ambi1.ogg'
#endif

/area/station2/captain //Three below this one are because Manta uses specific ambience on the bridge
	name = "Captain's Office"
	icon_state = "CAPN"

/area/station2/hos
	name = "Head of Personnel's Office"
	icon_state = "HOP"

/area/station2/hos/quarter
	name = "Head of Personnel's Personal Quarter"
	icon_state = "HOP"

/area/station2/bridge/captain
	name = "Captain's Office"
	icon_state = "CAPN"

/area/station2/bridge/hos
	name = "Head of Personnel's Office"
	icon_state = "HOP"

/area/station2/bridge/customs
	name = "Customs"
	icon_state = "yellow"

/area/station2/crew_quarters/quarters_north
	name = "North Crew Quarters"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/quarters_west
	name = "West Crew Quarters"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/quarters_east
	name = "East Crew Quarters"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/quarters_south
	name = "South Crew Quarters"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/hos
	name = "Head of Security's Quarters"
	icon_state = "HOS"
	sound_environment = 4

/area/station2/crew_quarters/md
	name = "Medical Director's Quarters"
	icon_state = "MD"
	sound_environment = 4

/area/station2/crew_quarters/ce
	name = "Chief Engineer's Quarters"
	icon_state = "CE"
	sound_environment = 4

/area/station2/crew_quarters/sauna
	name = "Sauna"
	icon_state = "crewquarters"
	sound_environment = 2
	requires_power = 1

/area/station2/crew_quarters/utility
	name = "Utility Room"
	icon_state = "orange"
	sound_environment = 2

/area/station2/crew_quarters/lounge
	name = "Crew Lounge"
	icon_state = "crew_lounge"
	sound_environment = 2

/area/station2/crew_quarters/lounge_port
	name = "West Crew Lounge"
	icon_state = "crew_lounge"
	sound_environment = 2

/area/station2/crew_quarters/lounge_starboard
	name = "East Crew Lounge"
	icon_state = "crew_lounge"
	sound_environment = 2

/area/station2/crew_quarters/locker
	name = "Locker Room"
	icon_state = "locker"
	sound_environment = 3

/area/station2/crew_quarters/stockex
	name = "Stock Exchange"
	icon_state = "yellow"
	sound_environment = 0

/area/station2/crew_quarters/radio
	name = "Radio Lab"
	icon_state = "green"
	sound_environment = 2

/area/station2/crew_quarters/radio/bathroom
	name = "Radio Lab Bathroom"

/area/station2/crew_quarters/arcade
	name = "Arcade"
	icon_state = "yellow"
	sound_environment = 4

/area/station2/crew_quarters/arcade/dungeon
	name = "Nerd Dungeon"
	icon_state = "purple"
	sound_environment = 5

/area/station2/crew_quarters/data
	name = "Data Center"
	icon_state = "purple"
	sound_environment = 5

/area/station2/crew_quarters/fitness
	name = "Fitness Room"
	icon_state = "fitness"
	sound_environment = 2

/area/station2/crew_quarters/captain
	name = "Captain's Quarters"
	icon_state = "captain"
	sound_environment = 4

/area/station2/crew_quarters/hop
	name = "Head of Personnel's Quarters"
	icon_state = "green"
	sound_environment = 4

/area/station2/crew_quarters/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"
	sound_environment = 0

	the_rising_tide_bar
		name = "The Rising Tide"


/area/station2/crew_quarters/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	sound_environment = 3

	freezer
		name = "Freezer"
		icon_state = "blue"

	therustykrab
		name = "The Rusty Krab"
		icon_state = "kitchen"

/area/station2/crew_quarters/clown
	name = "Clown Hole"
	icon_state = "storage"
	do_not_irradiate = 1

/area/station2/crew_quarters/catering
	name = "Catering Storage"
	icon_state = "storage"
	do_not_irradiate = 1

/area/station2/crew_quarters/bathroom
	name = "Bathroom"
	icon_state = "showers"

/area/station2/security/beepsky
	name = "Beepsky's House"
	icon_state = "storage"
	do_not_irradiate = 1

/area/station2/crew_quarters/jazz
	name = "Jazz Lounge"
	icon_state = "purple"

/area/station2/crew_quarters/info
	name = "Information Office"
	icon_state = "purple"

/area/station2/crew_quarters/bar
	name= "Bar"
	icon_state = "bar"
	sound_environment = 4

/area/station2/crew_quarters/baroffice
	name= "Bar Office"
	icon_state = "bar_office"
	sound_environment = 2

/area/station2/crew_quarters/heads
	name = "Head of Personnel's Office"
	icon_state = "HOP"
	sound_environment = 4

/area/station2/crew_quarters/hor
	name = "Research Director's Office"
	icon_state = "RD"
	sound_environment = 4
	requires_power = 1

	horprivate
	name = "Research Director's Private Quarters"
	icon_state = "RD"
	sound_environment = 4

/area/station2/crew_quarters/quarters
	name = "Crew Lounge"
	icon_state = "purple"
	sound_environment = 2

/area/station2/crew_quarters/quartersA
	name = "Crew Quarters A"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/quartersB
	name = "Crew Quarters B"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/quartersC
	name = "Crew Quarters C"
	icon_state = "crewquarters"
	sound_environment = 3

/area/station2/crew_quarters/toilets
	name = "Toilets"
	icon_state = "toilets"
	sound_environment = 3

/area/station2/crew_quarters/showers
	name = "Shower Room"
	icon_state = "showers"
	sound_environment = 3

/area/station2/crew_quarters/pool
	name = "Pool Room"
	icon_state = "showers"
	sound_environment = 3

/area/station2/crew_quarters/observatory
	name = "Observatory"
	icon_state = "observatory"
	sound_environment = 2

/area/station2/crew_quarters/courtroom
	name = "Courtroom"
	icon_state = "courtroom"
	sound_environment = 0

/area/station2/crew_quarters/juryroom
	name = "Jury Room"
	icon_state = "juryroom"
	sound_environment = 0

/area/station2/crew_quarters/barber_shop
	name = "Barber Shop"
	icon_state= "yellow"
	sound_environment = 2

/area/station2/crew_quarters/market
	name = "Public Market"
	icon_state = "yellow"
	sound_environment = 0

/area/station2/crew_quarters/garden
	name = "Public Garden"
	icon_state = "park"

area/station/crewquarters/garbagegarbs //It's the clothing store on Manta
	name = "Garbage Garbs clothing store"
	icon_state = "green"

area/station/crewquarters/cryotron
	name ="Cryogenic Crew Storage"
	icon_state = "blue"

/area/station2/com_dish/comdish
	name = "Communications Dish"
	icon_state = "yellow"
	force_fullbright = 1 // ????

/area/station2/com_dish/auxdish
	name = "Auxilary Communications Dish"
	icon_state = "yellow"
	force_fullbright = 1

/area/station2/com_dish/research_outpost
	name = "Research Outpost Communications Dish"
	icon_state = "yellow"
	force_fullbright = 1

/area/station2/engine
	sound_environment = 5
	workplace = 1

/area/station2/engine/engineering
	name = "Engineering"
	icon_state = "engineering"

/area/station2/engine/ptl
	name = "Power Transmission Laser"
	icon_state = "ptl"

/area/station2/engine/engineering/ce
	name = "Chief Engineer's Office"
	icon_state = "CE"

/area/station2/engine/engineering/ce/private
	name = "Chief Engineer's Private Quarters"
	icon_state = "CE"

/area/station2/engine/engineering/restroom
	name = "Engineering Restroom"
	icon_state = "toilets"

/area/station2/engine/engineering/breakroom
	name = "Engineering Break Room"
	icon_state ="showers"

/area/station2/engine/engineering/private
	name = "Engineering Quarters"
	icon_state = "yellow"

/area/mining/miningoutpost
	name = "Mining Outpost"
	icon_state = "engine"

/area/station2/engine/storage
	name = "Engineering Storage"
	icon_state = "engine_hallway"

/area/station2/engine/shield_gen
	name = "Engineering Shield Generator"
	icon_state = "engine_monitoring"

/area/station2/engine/shields
	name = "Engineering Shields"
	icon_state = "engine_monitoring"

/area/station2/engine/elect
	name = "Mechanic's Lab"
	icon_state = "mechanics"

/area/station2/engine/power
	name = "Engineering Power Room"
	icon_state = "showers"
	sound_environment = 5

/area/station2/engine/monitoring
	name = "Engineering Control Room"
	icon_state = "green"


/area/station2/engine/singcore
	name = "Singularity Core"
	icon_state = "red"

/area/station2/engine/eva
	name = "Engineering EVA"
	icon_state = "showers"

/area/station2/engine/core
	name = "Thermo-Electric Generator"
	icon_state = "teg" // sometimes you just gotta make an icon the way it is because that's what your heart tells you to do, even if it looks like something a cartoon for toddlers would reject for looking too stupid
	sound_environment = 10

/area/station2/engine/hotloop
	name = "Hot Loop"
	icon_state = "red"

/area/station2/engine/combustion_chamber
	name = "Combustion Chamber"
	icon_state = "combustion_chamber"

/area/station2/engine/coldloop
	name = "Cold Loop"
	icon_state = "purple"

/area/station2/engine/gas
	name = "Engineering Gas Storage"
	icon_state = "storage"
	sound_environment = 3

/area/station2/engine/inner
	name = "Inner Engineering"
	icon_state = "yellow"

/area/station2/engine/substation
	icon_state = "purple"
	sound_environment = 3

/area/station2/engine/substation/pylon
	name = "Electrical Substation"
	do_not_irradiate = 1

/area/station2/engine/substation/west
	name = "West Electrical Substation"
	do_not_irradiate = 1

/area/station2/engine/substation/east
	name = "East Electrical Substation"
	do_not_irradiate = 1

/area/station2/engine/substation/north
	name = "North Electrical Substation"
	do_not_irradiate = 1

/area/station2/engine/proto
	name = "Prototype Engine"
	icon_state = "prototype_engine"

/area/station2/engine/thermo
	name = "Thermoelectric generator"
	icon_state = "prototype_engine"

/area/station2/engine/proto_gangway
	name = "Prototype Gangway"
	icon_state = "green"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0

/area/station2/hangar
	name = "Hangar"
	icon_state = "purple"
	sound_environment = 10

/area/station2/teleporter
	name = "Teleporter"
	icon_state = "teleporter"
	sound_environment = 3
	workplace = 1

/area/syndicate_teleporter
	name = "Syndicate Teleporter"
	icon_state = "teleporter"
	requires_power = 0
	teleport_blocked = 1
	do_not_irradiate = 1

/area/station2/medical
	name = "Medical area"
	icon_state = "medbay"
	workplace = 1

/area/station2/medical/medbay
	name = "Medbay"
	icon_state = "medbay"
	sound_environment = 3

/area/station2/medical/medbay/lobby
	name = "Medbay Lobby"
	icon_state = "medbay_lobby"

/area/station2/medical/medbay/cloner
	name = "Cloning"
	icon_state = "cloner"

/area/station2/medical/medbay/pharmacy
	name = "Pharmacy"
	icon_state = "chem"

/area/station2/medical/medbay/treatment1
	name = "Treatment Room 1"
	icon_state = "treat1"

/area/station2/medical/medbay/treatment2
	name = "Treatment Room 2"
	icon_state = "treat2"

/area/station2/medical/medbay/restroom
	name = "Medbay Restroom"
	icon_state = "blue"

/area/station2/medical/medbay/surgery
	name = "Medbay Operating Theater"
	icon_state = "medbay_surgery"

/area/station2/medical/medbay/surgery/storage
	name = "Medical Storage"
	icon_state = "blue"

/area/station2/medical/robotics
	name = "Robotics"
	icon_state = "medresearch"

/area/station2/medical/research
	name = "Medical Research"
	icon_state = "medresearch"
	sound_environment = 3

/area/station2/medical/head
	name = "Medical Director's Office"
	icon_state = "MD"
	sound_environment = 1

	private
		name = "Medical Director's  Private Quarters"

/area/station2/medical/cdc
	name = "Pathology Research"
	icon_state = "medcdc"
	sound_environment = 5

/area/station2/medical/dome
	name = "Monkey Dome"
	icon_state = "green"
	sound_environment = 3

/area/station2/medical/morgue
	name = "Morgue"
	icon_state = "morgue"
	sound_environment = 3

/area/station2/medical/crematorium
	name = "Crematorium"
	icon_state = "morgue"
	sound_environment = 3

/area/station2/medical/medbooth
	name = "Medical Booth"
	icon_state = "medbooth"
	sound_environment = 3

/area/station2/medical/breakroom
	name = "Medbay Break Room"
	icon_state = "medbay_break"
	sound_environment = 3

/area/station2/medical/maintenance
	name = "Medical Maintenance"
	icon_state = "medical_maintenance"
	sound_environment = 3
	do_not_irradiate = 1

/area/station2/medical/staff
	name = "Medbay Staff Area"
	icon_state = "medbay_staff"
	sound_environment = 3

/area/station2/security
	teleport_blocked = 1
	workplace = 1

/area/station2/security/main
	name = "Security"
	icon_state = "security"
	sound_environment = 2

/area/station2/security/interrogation
	name = "Interrogation Room"
	icon_state = "red"
	sound_environment = 2

/area/station2/security/processing
	name = "Processing Room"
	icon_state = "red"
	sound_environment = 2

/area/station2/security/brig
	name = "Brig"
	icon_state = "brigcell"
	sound_environment = 3
	teleport_blocked = 0

	cell_block_control
		name = "Cell Block Control"
		icon_state = "orange"

	cell_block
		name = "Cell Block"
		icon_state = "brigcell"
	cell1
		name = "Cell #1"
		icon_state = "red"
	genpop
		name = "Genpop Cell"
		icon_state = "brig"
	solitary
		name = "Solitary Confinement"
		icon_state = "brig"



/area/station2/security/checkpoint
	name = "Bridge Security Checkpoint"
	icon_state = "checkpoint1"
	sound_environment = 2

	arrivals
		name = "Arrivals Security Checkpoint"
	escape
		name = "Escape Hallway Security Checkpoint"
	customs
		name = "Customs Security Checkpoint"
	sec_foyer
		name = "Security Foyer Checkpoint"
	podbay
		name = "Pod Bay Security Checkpoint"
	chapel
		name = "Chapel Security Checkpoint"
	cargo
		name = "Cargo Security Checkpoint"
	west
		name = "West Hallway Security Checkpoint"
	east
		name = "East Hallway Security Checkpoint"
	medical
		name = "Medical Security Checkpoint"

/area/station2/security/armory //what the fuck this is not the real armory???
	name = "Armory" //ai_monitored/armory is, shitty ass code
	icon_state = "armory"
	sound_environment = 2

/area/station2/security/prison
	name = "Prison Station"
	icon_state = "brig"
	sound_environment = 2

/area/station2/security/secwing
	name = "Security Wing"
	icon_state = "brig"
	sound_environment = 2

/area/station2/security/secoffquarters
	name = "Sec. Officers Quarters"
	icon_state = "brig"
	sound_environment = 2
	requires_power = 1

/area/station2/security/starboardtorpedoes
	name = "Starboard Torpedo Bay"
	icon_state = "torpedoes_starboard"
	sound_environment = 2
	requires_power = 1

/area/station2/security/porttorpedoes
	name = "Port Torpedo Bay"
	icon_state = "torpedoes_port"
	sound_environment = 2
	requires_power = 1

/area/station2/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	sound_environment = 4
	workplace = 1

/area/station2/security/detectives_office_manta
	name = "Detective's Office"
	icon_state = "detective"
	sound_environment = 15
	workplace = 1
	sound_loop = 'sound/ambience/station/detectivesoffice.ogg'
	sound_loop_vol = 30
	sound_group = "detective"

	detectives_bedroom
		name = "Detective's Bedroom"
		icon_state = "red"
		workplace = 0

/area/station2/security/hos
	name = "Head of Security's Office"
	icon_state = "HOS"
	sound_environment = 4
	workplace = 0 //As does the hos

area/station/security/visitation
	name ="Visitation"
	icon_state = "red"
	sound_environment = 4

/area/station2/solar
	requires_power = 0
	luminosity = 1
	force_fullbright = 1
	workplace = 1
	do_not_irradiate = 1

/area/station2/solar/north
	name = "North Solar Array"
	icon_state = "yellow"
	icon_state = "panelsN"

/area/station2/solar/south
	name = "South Solar Array"
	icon_state = "panelsS"

/area/station2/solar/east
	name = "East Solar Array"
	icon_state = "panelsE"

/area/station2/solar/west
	name = "West Solar Array"
	icon_state = "panelsW"

/area/station2/solar/small_backup1
	name = "Emergency Solar Array 1"
	icon_state = "yellow"

/area/station2/solar/small_backup2
	name = "Emergency Solar Array 2"
	icon_state = "yellow"

/area/station2/solar/small_backup3
	name = "Emergency Solar Array 3"
	icon_state = "yellow"

/area/station2/quartermaster
	name = "Quartermaster's"
	icon_state = "quart"
	workplace = 1

/area/station2/quartermaster/office
	name = "Quartermaster's Office"
	icon_state = "quartoffice"
	sound_environment = 10

/area/station2/quartermaster/storage
	name = "Quartermaster's Storage"
	icon_state = "quartstorage"
	sound_environment = 2
	do_not_irradiate = 1

/area/station2/quartermaster/magnet
	name = "Magnet Control Room"
	icon_state = "green"
	sound_environment = 10

/area/station2/quartermaster/refinery
	name = "Refinery"
	icon_state = "green"
	sound_environment = 10

/area/station2/quartermaster/cargobay
	name = "Cargo Bay"
	icon_state = "quartstorage"
	sound_environment = 10

/area/station2/quartermaster/cargooffice
	name = "Cargo Bay Office"
	icon_state = "quartoffice"
	sound_environment = 10

/area/station2/janitor
	name = "Janitor's Office"
	icon_state = "janitor"
	sound_environment = 3
	workplace = 1

/area/station2/janitor/supply
	name = "Janitor's Supply Closet"
	icon_state = "janitor"
	sound_environment = 3
	workplace = 1

/area/station2/chemistry
	name = "Chemistry"
	icon_state = "chem"
	sound_environment = 3
	workplace = 1

/area/station2/testchamber
	name = "Test Chamber"
	icon_state = "yellow"
	sound_environment = 5
	workplace = 1
	do_not_irradiate = 1

/area/station2/science
	//name = "Research Outpost Zeta"
	name = "Research Sector"
	icon_state = "purple"
	sound_environment = 3
	workplace = 1

/area/station2/science/gen_storage
	name = "Research Storage"
	icon_state = "genstorage"
	do_not_irradiate = 1

/area/station2/science/restroom
	name = "Research Restroom"
	icon_state = "purple"

/area/station2/science/bot_storage
	name = "Robot Depot"
	icon_state = "toxstorage"

/area/station2/science/teleporter
	name = "Science Teleporter"
	icon_state = "telelab"

/area/station2/science/research_director
	name = "Research Director's Office"
	icon_state = "toxlab"
	workplace = 0

/area/station2/science/lab
	name = "Toxin Lab"
	icon_state = "toxlab"

/area/station2/science/artifact
	name = "Artifact Lab"
	icon_state = "artifact"

/area/station2/science/storage
	name = "Toxin Storage"
	icon_state = "toxstorage"
	do_not_irradiate = 1

/area/station2/science/laser
	name = "Optics Lab"
	icon_state = "yellow"

/area/station2/science/spectral
	name = "Spectral Studies Lab"
	icon_state = "purple"

/area/station2/science/construction
	name = "Research Sector Construction Area"
	icon_state = "yellow"
	do_not_irradiate = 1

/area/station2/test_area
	name = "Toxin Test Area"
	icon_state = "toxtest"
	virtual = 1
	sound_group = "toxtest"
	force_fullbright = 1

/area/station2/chapel/main
	name = "Chapel"
	icon_state = "chapel"
	sound_environment = 7

/area/station2/chapel/main/main //wtf why is this a thing

/area/station2/chapel/office
	name = "Chapel Office"
	icon_state = "chapeloffice"
	sound_environment = 11

/area/station2/storage
	name = "Storage Area"
	icon_state = "storage"
	workplace = 1

/area/station2/storage/tools
	name = "Tool Storage"
	icon_state = "storage"
	sound_environment = 3

/area/station2/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"
	sound_environment = 3

/area/station2/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/station2/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/station2/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	sound_environment = 3

/area/station2/storage/eeva
	name = "Engineering EVA Storage"
	icon_state = "eva"

/area/station2/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/station2/storage/emergencyinternals
	name = "Emergency Internals"
	icon_state = "yellow"

/area/station2/storage/emergency
	name = "Emergency Storage A"
	icon_state = "emergencystorage"

/area/station2/storage/emergency2
	name = "Emergency Storage B"
	icon_state = "emergencystorage"

/area/station2/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"
	do_not_irradiate = 1

/area/station2/storage/warehouse
	name = "Central Warehouse"
	icon_state = "red"
	sound_environment = 18

/area/station2/storage/testroom
	requires_power = 0
	name = "Test Room"
	icon_state = "storage"
	teleport_blocked = 1

// cogmap new areas ///////////

/area/station2/hangar
	name = "Hangar"
	icon_state = "hangar"
	workplace = 1
	do_not_irradiate = 1

	main
		name = "Pod Bay"
		sound_environment = 10
	catering
		name = "Catering Dock"
	arrivals
		name = "Arrivals Dock"
	sec
		name = "Secure Dock"
		teleport_blocked = 1
	engine
		name = "Engineering Dock"
	qm
		name = "Cargo Dock"
	escape
		name = "Escape Dock"
	science
		name = "Research Dock"
		teleport_blocked = 1
	port
		name = "Submarine Bay (Port)"
		requires_power = 1
	starboard
		name = "Submarine Bay (Starboard)"
	mining
		name = "Submarine Bay (Mining)"
	security
		name = "Submarine Bay (Security)"

/area/station2/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	workplace = 1

/area/station2/hydroponics/lobby
	name = "Hydroponics Lobby"
	icon_state = "green"

/area/station2/owlery
	name = "Owlery"
	icon_state = "yellow"
	sound_environment = 15
	do_not_irradiate = 1

/area/station2/aviary
	name = "Aviary"
	icon_state = "aviary"
	sound_environment = 15
	do_not_irradiate = 1

/area/station2/habitat
	name = "Habitat Dome"
	icon_state = "aviary"
	sound_environment = 15
	do_not_irradiate = 1
	force_fullbright = 1

/area/station2/zen
	name = "Zen Garden"
	icon_state = "aviary"
	sound_environment = 15
	do_not_irradiate = 1

/area/station2/catwalk
	icon_state = "yellow"
	force_fullbright = 1

/area/station2/catwalk/north
	name = "North Maintenance Catwalk"

/area/station2/catwalk/south
	name = "South Maintenance Catwalk"

/area/station2/catwalk/west
	name = "West Maintenance Catwalk"

/area/station2/catwalk/east
	name = "East Maintenance Catwalk"

/area/station2/routingdepot
	name = "Routing Depot"
	icon_state = "depot"
	sound_environment = 13
	do_not_irradiate = 1

	catering
		name = "Cafeteria Router"

	eva
		name = "EVA Router"

	engine
		name = "Engine Router"

	medsci
		name = "Med-Sci Router"

	security
		name = "Security Router"

	airbridge
		name = "Airbridge Router"

/area/research_outpost
	name = "Research Outpost"
	icon_state = "blue"
	do_not_irradiate = 1

	hangar
		name = "Research Outpost Hangar"
		icon_state = "hangar"

	chamber
		name = "Research Outpost Test Chamber"
		icon_state = "yellow"

	maint
		name = "Research Outpost Maintenance"
		icon_state = "purple"
		do_not_irradiate = 1

	toxins
		name = "Research Outpost Toxins"
		icon_state = "green"

///////////////////////////////

/area/listeningpost
	name = "Listening Post"
	icon_state = "brig"
	teleport_blocked = 1
	do_not_irradiate = 1

	syndicateassaultvessel
		name ="Syndicate Assault Vessel"


/area/listeningpost/power
	name = "Listening Post Control Room"
	icon_state = "engineering"

/area/listeningpost/solars
	name = "Listening Post Solar Array"
	icon_state = "yellow"
	requires_power = 0
	luminosity = 1
	force_fullbright = 1

///////////////////////////////

/area/syndicate_station
	name = "Syndicate Station"
	icon_state = "yellow"
	requires_power = 0
	sound_environment = 2
	teleport_blocked = 1
	sound_group = "syndicate_station"

	battlecruiser
		name = "Syndicate Battlecruiser Cairngorm"
		icon_state = "red"
		sanctuary = 1

	firing_range
		name = "firing range"
		icon_state = "blue"

///////////////////////////////

/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	sound_environment = 4
	teleport_blocked = 1

	CanEnter( var/atom/movable/A )
		var/mob/living/M = A
		if( istype(M) && M.mind && M.mind.special_role != "wizard" && isliving(M) )
			if(M.client && M.client.holder)
				return 1
			boutput( M, "<span style='color:red'>A magical barrier prevents you from entering!</span>" )//or something
			return 0
		return 1

	//sanctuary = 1

///////////////////////////////

/area/station2/ai_monitored
	name = "AI Monitored Area"
	var/obj/machinery/camera/motion/motioncamera = null
	workplace = 1

/area/station2/ai_monitored/New()
	..()
	// locate and store the motioncamera
	SPAWN_DBG (20) // spawn on a delay to let turfs/objs load
		for (var/obj/machinery/camera/motion/M in src)
			motioncamera = M
			return
	return

/area/station2/ai_monitored/Entered(atom/movable/O)
	..()
	if (ismob(O) && motioncamera)
		motioncamera.newTarget(O)
//
/area/station2/ai_monitored/Exited(atom/movable/O)
	..()
	if (ismob(O) && motioncamera)
		motioncamera.lostTarget(O)

/area/station2/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"
	sound_environment = 12

/area/station2/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"
	sound_environment = 12

/area/station2/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"
	sound_environment = 12

/area/station2/ai_monitored/armory
	name = "Armory"
	icon_state = "armory"
	sound_environment = 2
	teleport_blocked = 1

///////////////////////////////

/area/station2/turret_protected
	name = "Turret Protected Area"
	var/list/obj/machinery/turret/turret_list = list()
	var/obj/machinery/camera/motion/motioncamera = null
	var/list/obj/blob/blob_list = list() //faster to cache blobs as they enter instead of searching the area for them (For turrets)

/area/station2/turret_protected/New()
	..()
	// locate and store the motioncamera
	SPAWN_DBG (20) // spawn on a delay to let turfs/objs load
		for (var/obj/machinery/camera/motion/M in src)
			motioncamera = M
			return
	return

/area/station2/turret_protected/Entered(O)
	..()
	if (isliving(O))
		if(!issilicon(O))
			if (motioncamera)
				motioncamera.newTarget(O)
			popUpTurrets()
	if (istype(O,/obj/blob))
		blob_list += O
	return 1

/area/station2/turret_protected/Exited(O)
	..()
	if (isliving(O))
		if (!issilicon(O))
			if(motioncamera)
				motioncamera.lostTarget(O)
			//popDownTurrets()
	if (istype(O,/obj/blob))
		blob_list -= O
	return 1

/area/station2/turret_protected/proc/popDownTurrets()
	for (var/obj/machinery/turret/aTurret in src.turret_list)
		aTurret.popDown()

/area/station2/turret_protected/proc/popUpTurrets()
	for (var/obj/machinery/turret/aTurret in src.turret_list)
		aTurret.popUp()


/area/station2/turret_protected/ai_upload
	name = "AI Upload Chamber"
	icon_state = "ai_upload"
	sound_environment = 12
	do_not_irradiate = 1

/area/station2/turret_protected/ai_upload_foyer
	name = "AI Upload Foyer"
	icon_state = "ai_foyer"
	sound_environment = 12

/area/station2/turret_protected/ai
	name = "AI Chamber"
	icon_state = "ai_chamber"
	sound_environment = 12
	do_not_irradiate = 1

/area/station2/turret_protected/AIbasecore1
	name = "AI Core 1"
	icon_state = "AIt"
	sound_environment = 12

/area/station2/turret_protected/AIbaseoutside
	name = "AI Perimeter Defenses"
	icon_state = "AIt"
	requires_power = 0
	sound_environment = 12

/area/station2/turret_protected/AIbasecore2
	name = "AI Core 2"
	icon_state = "AIt"
	sound_environment = 12

/area/station2/turret_protected/Zeta
	name = "Computer Core"
	icon_state = "AIt"
	sound_environment = 12

/area/station2/turret_protected/port
	name = "AI Upload Foyer Port"
	sound_environment = 12
	icon_state = "ai_foyer"

/area/station2/turret_protected/starboard
	name = "AI Upload Foyer Starboard"
	sound_environment = 12
	icon_state = "ai_foyer"

#endif
