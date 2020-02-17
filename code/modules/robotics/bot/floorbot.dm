//Floorbot assemblies
/obj/item/toolbox_tiles
	desc = "It's a toolbox with tiles sticking out the top"
	name = "tiles and toolbox"
	icon = 'icons/obj/toolbots.dmi'
	icon_state = "toolbox_tiles"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS

/obj/item/toolbox_tiles_sensor
	desc = "It's a toolbox with tiles sticking out the top and a sensor attached"
	name = "tiles, toolbox and sensor arrangement"
	icon = 'icons/obj/toolbots.dmi'
	icon_state = "toolbox_tiles_sensor"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = TABLEPASS

//Floorbot
/obj/machinery/bot/floorbot
	name = "Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/obj/toolbots.dmi'
	icon_state = "floorbot0"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	//weight = 1.0E7
	var/amount = 50
	on = 1
	var/repairing = 0
	var/improvefloors = 0
	var/eattiles = 0
	var/maketiles = 0
	locked = 1
	health = 25
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	req_access = list(access_engineering)
	access_lookup = "Chief Engineer"
	var/list/path = null
	no_camera = 1

/obj/machinery/bot/floorbot/New()
	..()
	SPAWN_DBG (5)
		if (src)
			src.botcard = new /obj/item/card/id(src)
			src.botcard.access = get_access(src.access_lookup)
			src.updateicon()
	return

/obj/machinery/bot/floorbot/attack_hand(mob/user as mob, params)
	var/dat
	dat += text({"
<TT><B>Automatic Station Floor Repairer v1.0</B></TT><BR><BR>
Status: []<BR>
Tiles left: [src.amount]<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},
text("<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"))
	if(!src.locked)
		dat += text({"<hr>
Improves floors: []<BR>
Finds tiles: []<BR>
Make single pieces of metal into tiles when empty: []"},
text("<A href='?src=\ref[src];operation=improve'>[src.improvefloors ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=tiles'>[src.eattiles ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=make'>[src.maketiles ? "Yes" : "No"]</A>"))

	if (user.client.tooltipHolder)
		user.client.tooltipHolder.showClickTip(src, list(
			"params" = params,
			"title" = "Repairbot v1.0 controls",
			"content" = dat,
		))

	return

/obj/machinery/bot/floorbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span style=\"color:red\">You short out [src]'s target assessment circuits.</span>")
		SPAWN_DBG(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span style=\"color:red\"><B>[src] buzzes oddly!</B></span>", 1)
		src.target = null
		src.oldtarget = null
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "floorbot[src.on]"
		return 1
	return 0


/obj/machinery/bot/floorbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s target assessment circuits.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/floorbot/emp_act()
	..()
	if (!src.emagged && prob(75))
		src.visible_message("<span style=\"color:red\"><B>[src] buzzes oddly!</B></span>")
		src.target = null
		src.oldtarget = null
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "floorbot[src.on]"
	else
		src.explode()
	return

/obj/machinery/bot/floorbot/attackby(var/obj/item/W , mob/user as mob)
	if(istype(W, /obj/item/tile))
		var/obj/item/tile/T = W
		if(src.amount >= 50)
			return
		var/loaded = 0
		if(src.amount + T.amount > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.amount -= i
			loaded = i
		else
			src.amount += T.amount
			loaded = T.amount
			qdel(T)
		boutput(user, "<span style=\"color:red\">You load [loaded] tiles into the floorbot. He now contains [src.amount] tiles!</span>")
		src.updateicon()
	//Regular ID
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.allowed(usr))
			src.locked = !src.locked
			boutput(user, "You [src.locked ? "lock" : "unlock"] the [src] behaviour controls.")
		else
			boutput(user, "The [src] doesn't seem to accept your authority.")
		src.updateUsrDialog()



/obj/machinery/bot/floorbot/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			src.on = !src.on
			src.target = null
			src.oldtarget = null
			src.oldloc = null
			src.updateicon()
			src.path = null
			src.updateUsrDialog()
		if("improve")
			src.improvefloors = !src.improvefloors
			src.updateUsrDialog()
		if("tiles")
			src.eattiles = !src.eattiles
			src.updateUsrDialog()
		if("make")
			src.maketiles = !src.maketiles
			src.updateUsrDialog()

/obj/machinery/bot/floorbot/attack_ai()
	src.on = !src.on
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.updateicon()
	src.path = null

/obj/machinery/bot/floorbot/process()
	//checks to see if robot is on
	if(!src.on)
		return
	//checks to see if already repairing
	if(src.repairing)
		return
	var/list/floorbottargets = list()
	//checks if already targeting something
	if(!src.target || src.target == null)
		for(var/obj/machinery/bot/floorbot/bot in machines)
			if(bot != src)
				floorbottargets += bot.target
	///Code for handling when out of tiles
	if(src.amount <= 0 && ((src.target == null) || !src.target))
		if(src.eattiles)
			for(var/obj/item/tile/T in view(7, src))
				if(T != src.oldtarget && !(target in floorbottargets))
					src.oldtarget = T
					src.target = T
					break
		if(src.target == null || !src.target)
			if(src.maketiles)
				if(src.target == null || !src.target)
					for(var/obj/item/sheet/M in view(7, src))
						if(!(M in floorbottargets) && M != src.oldtarget && M.amount == 1 && !(istype(M.loc, /turf/simulated/wall)))
							src.oldtarget = M
							src.target = M
							break
		else
			return
	if(prob(5))
		src.visible_message("[src] makes an excited booping beeping sound!")
	/////////Search for target code
	if((!src.target || src.target == null) && (!src.emagged))
	    ///Search for space turf
		for (var/turf/space/D in view(7,src))
			if(!(D in floorbottargets) && D != src.oldtarget && ((D.loc.name != "Space") || (D.loc.name != "Ocean")) )
				src.oldtarget = D
				src.target = D
				break
		///Search for incomplete floor
		if((!src.target || src.target == null ) && src.improvefloors)
			for (var/turf/simulated/floor/F in view(7,src))
				if(!(F in floorbottargets) && F != src.oldtarget && (istype(F, /turf/simulated/floor/plating)))
					src.oldtarget = F
					src.target = F
					break
		///search for tiles
		if((!src.target || src.target == null) && src.eattiles)
			for(var/obj/item/tile/T in view(7, src))
				if(!(T in floorbottargets) && T != src.oldtarget)
					src.oldtarget = T
					src.target = T
					break
	else if((!src.target || src.target == null) && (src.emagged))
		for (var/turf/simulated/floor/F in view(7,src))
			if(!(F in floorbottargets) && F != src.oldtarget)
				src.oldtarget = F
				src.target = F
				break

	if(!src.target || src.target == null)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && (!src.path || !src.path.len))
		SPAWN_DBG(0)
			if (!isturf(src.loc))
				return
			if (!target)
				return
			src.path = AStar(src.loc, get_turf(src.target), /turf/proc/CardinalTurfsSpace, /turf/proc/Distance, 120)
			if (!src.path || !src.path.len)
				src.oldtarget = src.target
				src.target = null
		return
	if(src.path && src.path.len && src.target)
		step_to(src, src.path[1])
		src.path -= src.path[1]

	if(src.loc == src.target || src.loc == src.target.loc)
		if(istype(src.target, /obj/item/tile))
			src.eattile(src.target)
		else if(istype(src.target, /obj/item/sheet))
			src.maketile(src.target)
		else if(istype(src.target, /turf/))
			repair(src.target)
		src.path = null
		return

	src.oldloc = src.loc


/obj/machinery/bot/floorbot/proc/repair(var/turf/target)
	if(istype(target, /turf/space/))
		if(target.loc.name == "Space" || target.loc.name == "Ocean")
			return
	else if(!istype(target, /turf/simulated/floor))
		return
	if(src.amount <= 0 && (!src.emagged))
		return
	src.anchored = 1
	src.icon_state = "floorbot-c"
	if(istype(target, /turf/space/))
		src.visible_message("<span style=\"color:red\">[src] begins to repair the hole</span>")
		var/obj/item/tile/T = new /obj/item/tile
		src.repairing = 1
		SPAWN_DBG(20)
			T.build(src.loc)
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null
	/////////////////////////////////////////////////
	///Emagged "repair"       ///////////////////////
	/////////////////////////////////////////////////
	if((istype(target, /turf/simulated/floor)) && (src.emagged))
		src.visible_message("<span style=\"color:red\">[src] begins to remove the tile</span>")
		src.repairing = 1
		SPAWN_DBG(20)
			qdel(target)
			src.repairing = 0
			src.updateicon()
			src.anchored = 0
			src.target = null
	else
		src.visible_message("<span style=\"color:red\">[src] begins to improve the floor.</span>")
		src.repairing = 1
		SPAWN_DBG(20)
			src.loc.icon_state = "floor"
			src.repairing = 0
			src.amount -= 1
			src.updateicon()
			src.anchored = 0
			src.target = null

/obj/machinery/bot/floorbot/proc/eattile(var/obj/item/tile/T)
	if(!istype(T, /obj/item/tile))
		return
	src.visible_message("<span style=\"color:red\">[src] begins to collect tiles.</span>")
	src.repairing = 1
	SPAWN_DBG(20)
		if(isnull(T))
			src.target = null
			src.repairing = 0
			return
		if(src.amount + T.amount > 50)
			var/i = 50 - src.amount
			src.amount += i
			T.amount -= i
		else
			src.amount += T.amount
			qdel(T)
		src.updateicon()
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/maketile(var/obj/item/sheet/M)
	if(!istype(M, /obj/item/sheet))
		return
	if(M.amount > 1)
		return
	src.visible_message("<span style=\"color:red\">[src] begins to create tiles.</span>")
	src.repairing = 1
	SPAWN_DBG(20)
		if(isnull(M))
			src.target = null
			src.repairing = 0
			return
		var/obj/item/tile/T = new /obj/item/tile/steel
		T.amount = 4
		T.set_loc(M.loc)
		qdel(M)
		src.target = null
		src.repairing = 0

/obj/machinery/bot/floorbot/proc/updateicon()
	if (src.amount > 0)
		src.icon_state = "floorbot[src.on]"
	else
		src.icon_state = "floorbot[src.on]e"


/////////////////////////////////////////
//////Floorbot Construction/////////////
/////////////////////////////////////////
/obj/item/storage/toolbox/mechanical/attackby(var/obj/item/tile/T, mob/user as mob)
	if(!istype(T, /obj/item/tile))
		..()
		return
	if(src.contents.len >= 1)
		boutput(user, "They wont fit in as there is already stuff inside!")
		return
	var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles
	user.u_equip(T)
	user.put_in_hand_or_drop(B)
	boutput(user, "You add the tiles into the empty toolbox. They stick oddly out the top.")
	qdel(T)
	qdel(src)

/obj/item/toolbox_tiles/attackby(var/obj/item/device/prox_sensor/D, mob/user as mob)
	if(!istype(D, /obj/item/device/prox_sensor))
		return
	var/obj/item/toolbox_tiles_sensor/B = new /obj/item/toolbox_tiles_sensor
	B.set_loc(user)
	user.u_equip(D)
	user.put_in_hand_or_drop(B)
	boutput(user, "You add the sensor to the toolbox and tiles!")
	qdel(D)
	qdel(src)

/obj/item/toolbox_tiles_sensor/attackby(var/obj/item/parts/robot_parts/P, mob/user as mob)
	if(!istype(P, /obj/item/parts/robot_parts/arm/))
		return
	var/obj/machinery/bot/floorbot/A = new /obj/machinery/bot/floorbot
	if(user.r_hand == src || user.l_hand == src)
		A.set_loc(user.loc)
	else
		A.set_loc(src.loc)
	boutput(user, "You add the robot arm to the odd looking toolbox assembly! Boop beep!")
	qdel(P)
	qdel(src)

/obj/machinery/bot/floorbot/explode()
	src.on = 0
	for(var/mob/O in hearers(src, null))
		O.show_message("<span style=\"color:red\"><B>[src] blows apart!</B></span>", 1)
	var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return
