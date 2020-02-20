/*
CONTAINS:
RCD
Broken RCD + Effects
*/

#define RCD_MODE_FLOORSWALLS 1
#define RCD_MODE_AIRLOCK 2
#define RCD_MODE_DECONSTRUCT 3
#define RCD_MODE_WINDOWS 4
#define RCD_MODE_PODDOORCONTROL 5
#define RCD_MODE_PODDOOR 6

/*
	@TODO Fix the description stuff so it isn't manually updated constantly
	(get_desc is a thing!)
	Also maybe better handling; use on walls to reinforce?, that sort of thing
	maybe deconstructing an rwall turns into a normal wall first, etc
	hm hm

	also maybe an assoc list instead of matter_shit_fuck
*/

/obj/item/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/max_matter = 50
	var/working = 0
	var/mode = 1
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	var/datum/effects/system/spark_spread/spark_system
	mats = 12
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	module_research = list("tools" = 8, "engineering" = 8, "devices" = 3, "efficiency" = 5)
	module_research_type = /obj/item/rcd

	var/matter_create_floor = 1
	var/matter_create_wall = 2
	var/matter_create_wall_girder = 1
	var/matter_create_door = 5
	var/matter_create_window = 2
	var/matter_remove_door = 15
	var/matter_remove_floor = 8
	var/matter_remove_wall = 8
	var/matter_remove_girder = 8
	var/matter_remove_window = 8

	var/material_name = "steel"

	cyborg
		material_name = "electrum"

/obj/item/rcd/construction
	name = "rapid-construction-device (RCD) deluxe"
	desc = "A device used to rapidly construct."
	max_matter = 15000

	matter_remove_door = 3
	matter_remove_wall = 2
	matter_remove_floor = 2

	var/static/hangar_id_number = 1
	var/hangar_id = null
	var/door_name = null
	var/door_access = 0
	var/door_access_name_cache = null

	var/static/list/access_names = list()
	var/door_type = null

/obj/item/rcd_fake
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0


// Doesn't shit out sparks everywhere, that's it. Doesn't even have any different vars
// Used for ghostdrones to prevent explode
/obj/item/rcd/rcd_safe
	shitSparks()
		return

/obj/item/rcd/construction/safe
	shitSparks()
		return


/obj/item/rcd_ammo
	name = "Compressed matter cartridge"
	desc = "Highly compressed matter for a rapid construction device."
	icon = 'icons/obj/ammo.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	m_amt = 30000
	g_amt = 15000
	var/matter = 10

	examine()
		..()
		boutput(usr, "It contains [matter] units of ammo.")

/obj/item/rcd_ammo/medium
	name = "Medium compressed matter cartridge"
	matter = 50

/obj/item/rcd_ammo/big
	name = "Large compressed matter cartridge"
	matter = 100

/obj/item/rcd/New()
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = unpool(/datum/effects/system/spark_spread)
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/rcd/proc/shitSparks()
	spark_system.set_up(5, 0, src)
	src.spark_system.start()

/obj/item/rcd/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/rcd_ammo))
		if (!W:matter)
			return
		if (matter == max_matter)
			boutput(user, "\the [src] can't hold any more matter.")
			return
		if (matter + W:matter > max_matter)
			W:matter -= (max_matter - matter)
			boutput(user, "The cartridge now contains [W:matter] units of matter.")
			matter = max_matter
		else
			matter += W:matter
			W:matter = 0
			qdel(W)
		playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
		boutput(user, "\the [src] now holds [matter]/[max_matter] matter-units.")
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
		return

/obj/item/rcd/attack_self(mob/user as mob)
	playsound(get_turf(src), "sound/effects/pop.ogg", 50, 0)

	switch (mode)
		if (RCD_MODE_FLOORSWALLS)
			mode = RCD_MODE_AIRLOCK
			boutput(user, "Changed mode to 'Airlock'")

		if (RCD_MODE_AIRLOCK)
			mode = RCD_MODE_DECONSTRUCT
			boutput(user, "Changed mode to 'Deconstruct'")

		if (RCD_MODE_DECONSTRUCT)
			mode = RCD_MODE_WINDOWS
			boutput(user, "Changed mode to 'Windows'")

		else	// RCD_MODE_WINDOWS or RCD_MODE_PODDOOR
			mode = RCD_MODE_FLOORSWALLS
			boutput(user, "Changed mode to 'Floors and Walls'")

	src.shitSparks()
	return

/obj/item/rcd/construction/attack_self(mob/user as mob)
	// Swap to extra mode instead of wrapping around
	if (mode != RCD_MODE_WINDOWS)
		..()
	else
		mode = RCD_MODE_PODDOORCONTROL
		boutput(user, "Changed mode to 'Pod Door Control'")
		boutput(user, "<span style=\"color:blue\">Place a door control on a wall, then place any amount of pod doors on floors.</span>")
		boutput(user, "<span style=\"color:blue\">You can also select an existing door control by whacking it with \the [src].</span>")
		return

/obj/item/rcd/proc/create_door(var/turf/A, mob/user as mob)
	boutput(user, "Building Airlock ([matter_create_door])...")
	playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
	if(do_after(user, 50))
		if (rcd_ammocheck(user, matter_create_door))
			src.shitSparks()
			var/interim = fetchAirlock()
			var/obj/machinery/door/airlock/T = new interim(A)
			logTheThing("station", user, null, "builds an airlock ([T]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
			rcd_ammoconsume(user, matter_create_door)
			if(map_setting == "COG2") T.dir = user.dir
			T.autoclose = 1
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			playsound(get_turf(src), "sound/effects/sparks2.ogg", 50, 1)

/obj/item/rcd/construction/create_door(var/turf/A, mob/user as mob)
	var/turf/L = get_turf(user)
	var/set_data = 0
	if (door_name)
		if (alert("Use saved data?",,"Yes","No") == "No")
			set_data = 1
	else
		set_data = 1
	if (set_data)
		door_name = copytext(adminscrub(input("Door name", "RCD", door_name) as text), 1, 512)
		if (!access_names.len)
			for (var/access in get_all_accesses())
				var/access_name = get_access_desc(access)
				access_names[access_name] = access
		door_access_name_cache = input("Required access", "RCD", door_access_name_cache) in access_names
		door_access = access_names[door_access_name_cache]
		door_type = alert("Select airlock variant","RCD","Standard","Glass","Alternate")

	if (user.loc != L)
		boutput(user, "<span style=\"color:red\">Stand still you oaf.</span>")
		return

	boutput(user, "Building Airlock ([matter_create_door])...")
	playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
	if(do_after(user, 50))
		if (rcd_ammocheck(user, matter_create_door))
			src.shitSparks()
			var/interim = fetchAirlock(door_access,door_type)
			var/obj/machinery/door/airlock/T = new interim(A)
			logTheThing("station", user, null, "builds an airlock ([T], name: [door_name], access: [door_access]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
			rcd_ammoconsume(user, matter_create_door)
			if(map_setting == "COG2") T.dir = user.dir
			T.autoclose = 1
			T.name = door_name
			T.req_access = list(door_access)
			T.req_access_txt = "[door_access]"
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			playsound(get_turf(src), "sound/effects/sparks2.ogg", 50, 1)

/obj/item/rcd/construction/afterattack(atom/A, mob/user as mob)
	..()
	if (mode == RCD_MODE_DECONSTRUCT)
		if (istype(A, /obj/machinery/door/poddoor/blast) && rcd_ammocheck(user, matter_remove_door, 500))
			var /obj/machinery/door/poddoor/blast/B = A
			if (findtext(B.id, "rcd_built") != 0)
				boutput(user, "Deconstructing \the [B] ([matter_remove_door])...")
				playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
				if(do_after(user, 50))
					if (rcd_ammocheck(user, matter_remove_door))
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
						src.shitSparks()
						rcd_ammoconsume(user, matter_remove_door)
						logTheThing("station", user, null, "removes a pod door ([B]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
						qdel(A)
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			else
				boutput(user, "<span style=\"color:red\">You cannot deconstruct that!</span>")
				return
		else if (istype(A, /obj/machinery/r_door_control) && rcd_ammocheck(user, matter_remove_door, 500))
			var/obj/machinery/r_door_control/R = A
			if (findtext(R.id, "rcd_built") != 0)
				boutput(user, "Deconstructing \the [R] ([matter_remove_door])...")
				playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
				if(do_after(user, 50))
					if (rcd_ammocheck(user, matter_remove_door))
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
						src.shitSparks()
						rcd_ammoconsume(user, matter_remove_door)
						logTheThing("station", user, null, "removes a Door Control ([A]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
						qdel(A)
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			else
				boutput(user, "<span style=\"color:red\">You cannot deconstruct that!</span>")
				return
	else if (mode == RCD_MODE_PODDOORCONTROL)
		if (istype(A, /obj/machinery/r_door_control))
			var/obj/machinery/r_door_control/R = A
			if (findtext(R.id, "rcd_built") != 0)
				boutput(user, "<span style=\"color:blue\">Selected.</span>")
				hangar_id = R.id
				mode = RCD_MODE_PODDOOR
			else
				boutput(user, "<span style=\"color:red\">You cannot modify that!</span>")
		else if (istype(A, /turf/simulated/wall) && rcd_ammocheck(user, matter_create_door, 500))
			boutput(user, "Creating Door Control ([matter_create_door])")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_create_door))
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
					src.shitSparks()
					var/idn = hangar_id_number
					hangar_id_number++
					hangar_id = "rcd_built_[idn]"
					mode = RCD_MODE_PODDOOR
					var/obj/machinery/r_door_control/R = new /obj/machinery/r_door_control(A)
					R.id="[hangar_id]"
					R.pass="[hangar_id]"
					R.name="Access code: [hangar_id]"
					rcd_ammoconsume(user, matter_create_door)
					logTheThing("station", user, null, "creates Door Control [hangar_id] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					boutput(user, "Now creating pod bay blast doors linked to the new door control.")

	else if (mode == RCD_MODE_PODDOOR)
		if (istype(A, /turf/simulated/floor) && rcd_ammocheck(user, matter_create_door, 500))
			boutput(user, "Creating Pod Bay Door ([matter_create_door])")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_create_door))
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
					src.shitSparks()
					var/stepdir = get_dir(src, A)
					var/poddir = turn(stepdir, 90)
					var/obj/machinery/door/poddoor/blast/B = new /obj/machinery/door/poddoor/blast(A)
					B.id = "[hangar_id]"
					B.dir = poddir
					B.autoclose = 1
					rcd_ammoconsume(user, matter_create_door)
					logTheThing("station", user, null, "creates Blast Door [hangar_id] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")

/obj/item/rcd/afterattack(atom/A, mob/user as mob)
	if (get_dist(get_turf(src), get_turf(A)) > 1)
		return

	if (mode == RCD_MODE_FLOORSWALLS)
		if ((istype(A, /obj/lattice) || istype(A, /turf/space)) && rcd_ammocheck(user, matter_create_floor, 50))
			if (istype(A, /obj/lattice))
				var/turf/L = get_turf(A)
				if (!istype(L, /turf/space)) return
				A = L

			boutput(user, "Building a floor ([matter_create_floor])...")
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			src.shitSparks()
			var/turf/simulated/floor/T = A:ReplaceWithFloor()
			T.inherit_area()
			T.setMaterial(getMaterial(material_name))
			rcd_ammoconsume(user, matter_create_floor)
			return

		if (istype(A, /turf/simulated/floor) && rcd_ammocheck(user, matter_create_wall, 150))
			boutput(user, "Building a wall ([matter_create_wall])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 20))
				if (rcd_ammocheck(user, matter_create_wall))
					src.shitSparks()
					var/datum/material/M = A:material
					var/turf/simulated/wall/T = A:ReplaceWithWall()
					T.inherit_area()
					if (M)
						T.setMaterial(M)
					else
						T.setMaterial(getMaterial(material_name))

					logTheThing("station", user, null, "builds \a [T] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
					rcd_ammoconsume(user, matter_create_wall)
			return
		if (istype(A, /obj/structure/girder) && !istype(A, /obj/structure/girder/displaced) && rcd_ammocheck(user, matter_create_wall_girder, 50))
			boutput(user, "Building a wall on \the [A] ([matter_create_wall_girder])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 20))
				if (rcd_ammocheck(user, matter_create_wall_girder))
					src.shitSparks()
					var/datum/material/M = A:material
					var/turf/wallTurf = get_turf(A)

					var/turf/simulated/wall/T
					if (istype(A, /obj/structure/girder/reinforced))
						T = wallTurf:ReplaceWithRWall()
					else
						T = wallTurf:ReplaceWithWall()

					if (M)
						T.setMaterial(M)
					else
						T.setMaterial(getMaterial(material_name))

					logTheThing("station", user, null, "builds \a [T] on \a [A] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					qdel(A)

					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
					rcd_ammoconsume(user, matter_create_wall_girder)
			return

	else if (mode == RCD_MODE_AIRLOCK && rcd_ammocheck(user, matter_create_door, 1000) && istype(A, /turf/simulated/floor))
		create_door(A, user)
		return

	else if (mode == RCD_MODE_DECONSTRUCT)
		if (istype(A, /turf/simulated/wall) && rcd_ammocheck(user, matter_remove_wall, 500))
			boutput(user, "Deconstructing \the [A] ([matter_remove_wall])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_wall))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_wall)
					var/datum/material/M = A:material
					var/turf/simulated/floor/T = A:ReplaceWithFloor()
					if (M)
						T.setMaterial(M)
					else
						T.setMaterial(getMaterial(material_name))

					logTheThing("station", user, null, "removes \a [A] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return
		if ((istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced)) && rcd_ammocheck(user, matter_remove_wall, 500))
			boutput(user, "Deconstructing \the [A] ([matter_remove_wall])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_door))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_wall)
					var/datum/material/M = A:material
					var/turf/simulated/wall/T = A:ReplaceWithWall()
					if (M)
						T.setMaterial(M)
					else
						T.setMaterial(getMaterial(material_name))

					logTheThing("station", user, null, "removes \a [A] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return
		if (istype(A, /turf/simulated/floor) && rcd_ammocheck(user, matter_remove_floor, 500))
			boutput(user, "Deconstructing Floor ([matter_remove_floor])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_floor))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_floor)
					logTheThing("station", user, null, "removes the floor ([A]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					A:ReplaceWithSpace()
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return

		if (istype(A, /obj/machinery/door/airlock) && rcd_ammocheck(user, matter_remove_door, 500))
			var/obj/machinery/door/airlock/AL = A
			if (AL.hardened == 1)
				boutput(user, "<span style=\"color:red\">\The [AL] is reinforced against rapid deconstruction!</span>")
				return
			boutput(user, "Deconstructing \the [AL] ([matter_remove_door])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_door))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_door)
					logTheThing("station", user, null, "removes an airlock ([AL]) using \the [src] at [log_loc(user)].")
					qdel(AL)
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return

		if (istype(A, /obj/structure/girder) && rcd_ammocheck(user, matter_remove_girder, 500))
			boutput(user, "Deconstructing \the [A] ([matter_remove_girder])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_girder))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_girder)
					logTheThing("station", user, null, "removes \a [A] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					qdel(A)

					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return

		if (istype(A, /obj/window) && rcd_ammocheck(user, matter_remove_window, 500))
			boutput(user, "Deconstructing \the [A] ([matter_remove_window])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_window))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_window)
					logTheThing("station", user, null, "removes \a [A] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					qdel(A)

					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return

		if (istype(A, /obj/lattice) && rcd_ammocheck(user, matter_remove_floor, 500))
			boutput(user, "Deconstructing \the [A] ([matter_remove_floor])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (rcd_ammocheck(user, matter_remove_floor))
					src.shitSparks()
					rcd_ammoconsume(user, matter_remove_floor)
					logTheThing("station", user, null, "removes \a [A] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					qdel(A)
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			return

	else if (mode == 4)
		if (istype(A, /turf/simulated/floor) && rcd_ammocheck(user, matter_create_window, 150))
			boutput(user, "Building window ([matter_create_window])...")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 20))
				if (rcd_ammocheck(user, matter_create_window))
					src.shitSparks()
					// @TODO check if theres a better way to pick
					//if (ismap("COGMAP2"))
					new/obj/window/auto(get_turf(A))
					//else
					//	new/obj/window(get_turf(A))

					logTheThing("station", user, null, "builds a window using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
					rcd_ammoconsume(user, matter_create_window)
			return

/*
// holy jesus christ
/obj/item/rcd/attack(mob/M as mob, mob/user as mob, def_zone)
	if (ishuman(M) && matter >= 3)
		var/mob/living/carbon/human/H = M
		if(!isdead(H) && H.health > 0)
			boutput(user, "<span style=\"color:red\">You poke [H] with \the [src].</span>")
			boutput(H, "<span style=\"color:red\">[user] pokes you with \the [src].</span>")
			return
		boutput(user, "<span style=\"color:red\"><B>You shove \the [src] down [H]'s mouth and pull the trigger!</B></span>")
		H.show_message("<span style=\"color:red\"><B>[user] is shoving an RCD down your throat!</B></span>", 1)
		for(var/mob/N in viewers(user, 3))
			if(N.client && N != user && N != H)
				N.show_message(text("<span style=\"color:red\"><B>[] shoves \the [src] down []'s throat!</B></span>", user, H), 1)
		playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
		if(do_after(user, 20))
			spark_system.set_up(5, 0, src)
			src.spark_system.start()
			var/mob/living/carbon/wall/W = new(H.loc)
			W.real_name = H.real_name
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			playsound(get_turf(src), "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			if(H.mind)
				H.mind.transfer_to(W)
			H.gib()
			matter -= 3
			boutput(user, "\the [src] now holds [matter]/30 matter-units.")
			desc = "A RCD. It currently holds [matter]/30 matter-units."
		return
	else
		return ..(M, user, def_zone)
*/

/obj/item/rcd/proc/rcd_ammocheck(mob/user as mob, var/checkamt = 0)
	if (isrobot(user))
		var/mob/living/silicon/robot/R = user
		if (R.cell.charge >= checkamt * 5) return 1
		else return 0
	else if (isghostdrone(user))
		var/mob/living/silicon/ghostdrone/R = user
		if (R.cell.charge >= checkamt * 5) return 1
		else return 0
	else
		if (src.matter >= checkamt) return 1
		else return 0

/obj/item/rcd/proc/rcd_ammoconsume(mob/user as mob, var/checkamt = 0)
	if (isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= checkamt * 125
	else if (isghostdrone(user))
		var/mob/living/silicon/ghostdrone/R = user
		R.cell.charge -= checkamt * 125
	else
		src.matter -= checkamt
		boutput(user, "\the [src] now holds [src.matter]/[src.max_matter] matter-units.")
		src.desc = "A RCD. It currently holds [src.matter]/[src.max_matter] matter-units."

//Broken RCDs.  Attempting to use them is...ill advised.
/obj/item/broken_rcd
	name = "prototype rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	icon_state = "bad_rcd0"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rcd"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	var/mode = 1
	var/broken = 0 //Fully broken, that is.
	var/datum/effects/system/spark_spread/spark_system

	New()
		..()
		src.icon_state = "bad_rcd[rand(0,2)]"
		src.spark_system = unpool(/datum/effects/system/spark_spread)
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/rcd_ammo))
			boutput(user, "\the [src] slot is not compatible with this cartridge.")
			return

	attack_self(mob/user as mob)
		if (src.broken)
			boutput(user, "<span style=\"color:red\">It's broken!</span>")
			return

		playsound(src.loc, "sound/effects/pop.ogg", 50, 0)
		if (mode)
			mode = 0
			boutput(user, "Changed mode to 'Deconstruct'")
			src.spark_system.start()
			return
		else
			mode = 1
			boutput(user, "Changed mode to 'Floor & Walls'")
			src.spark_system.start()
			return

	afterattack(atom/A, mob/user as mob)
		if (src.broken > 1)
			boutput(user, "<span style=\"color:red\">It's broken!</span>")
			return

		if (!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return
		if ((istype(A, /turf/space) || istype(A, /turf/simulated/floor)) && mode)
			if (src.broken)
				boutput(user, "<span style=\"color:red\">Insufficient charge.</span>")
				return

			boutput(user, "Building [istype(A, /turf/space) ? "Floor (1)" : "Wall (3)"]...")

			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 20))
				if (src.broken)
					return

				src.broken++
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

				for (var/turf/T in orange(1,user))
					T.ReplaceWithWall()


				boutput(user, "<span style=\"color:red\">\the [src] shorts out!</span>")
				return

		else if (!mode)
			boutput(user, "Deconstructing ??? ([rand(1,8)])...")

			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			if(do_after(user,50))
				if (src.broken)
					return

				src.broken++
				spark_system.set_up(5,0,src)
				src.spark_system.start()
				playsound(src.loc, "sound/items/Deconstruct.ogg", 100, 1)

				boutput(user, "<span class='combat'>\the [src] shorts out!</span>")

				logTheThing("combat", user, null, "manages to vaporize \[[showCoords(A.x, A.y, A.z)]] with a halloween RCD.")

				new /obj/effects/void_break(A)
				if (user)
					user.gib()

/obj/effects/void_break
	invisibility = 101
	anchored = 1
	var/lifespan = 4
	var/rangeout = 0

	New()
		..()
		lifespan = rand(2,4)
		rangeout = lifespan
		SPAWN_DBG(5 DECI SECONDS)
			void_shatter()
			void_loop()

	proc/void_shatter()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 80, 1)
		for (var/atom/A in range(lifespan, src))
			if (istype(A, /turf/simulated))
				A.pixel_x = rand(-4,4)
				A.pixel_y = rand(-4,4)
			else if (isliving(A))
				shake_camera(A, 8, 3)
				A.ex_act( get_dist(src, A) > 1 ? 3 : 1 )

			else if (istype(A, /obj) && (A != src))

				if ((get_dist(src, A) <= 2) || prob(10))
					A.ex_act(1)
				else if (prob(5))
					A.ex_act(3)

				continue

		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(3, 1, src)
		s.start()

	proc/void_loop()
		if (lifespan-- < 0)
			qdel(src)
			return

		for (var/turf/simulated/T in range(src, (rangeout-lifespan)))
			if (prob(5 + lifespan) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = unpool(/obj/effects/sparks)
				sparks.set_loc(T)
				SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)

			T.ex_act((rangeout-lifespan) < 2 ? 1 : 2)

		SPAWN_DBG(1.5 SECONDS)
			void_loop()
		return
