/*
/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	density = 1
	anchored = 1.0

/obj/machinery/pipedispenser/attack_hand(user as mob)
	if(..())
		return

	var/dat = {"
<A href='?src=\ref[src];make=0'>Pipe<BR>
<A href='?src=\ref[src];make=1'>Bent Pipe<BR>
<A href='?src=\ref[src];make=2'>Heat Exchange Pipe<BR>
<A href='?src=\ref[src];make=3'>Heat Exchange Bent Pipe<BR>
<A href='?src=\ref[src];make=4'>Connector<BR>
<A href='?src=\ref[src];make=5'>Manifold<BR>
<A href='?src=\ref[src];make=6'>Junction<BR>
<A href='?src=\ref[src];make=7'>Vent<BR>
<A href='?src=\ref[src];make=8'>Valve<BR>
<A href='?src=\ref[src];make=9'>Pipe-Pump<BR>"}
//<A href='?src=\ref[src];make=10'>Filter Inlet<BR>


	user.Browse("<HEAD><TITLE>Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["make"])
		var/p_type = text2num(href_list["make"])
		var/obj/item/pipe/P = new /obj/item/pipe(src.loc)
		P.pipe_type = p_type
		P.update()

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	return

/obj/machinery/pipedispenser/New()
	..()
*/

/obj/machinery/disposal_pipedispenser
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab"
	density = 1
	anchored = 1.0
	mats = 16
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

/obj/machinery/disposal_pipedispenser/mobile
	name = "Disposal Pipe Dispenser Cart"
	desc = "A tool for removing some of the tedium from pipe-laying."
	anchored = 0
	icon_state = "fab-mobile"


/obj/machinery/disposal_pipedispenser/attack_hand(mob/user as mob)
	if(..())
		return

	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='?src=\ref[src];dmake=0'>Pipe</A><BR>
<A href='?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
<A href='?src=\ref[src];dmake=2'>Junction</A><BR>
<A href='?src=\ref[src];dmake=3'>Y-Junction</A><BR>
<A href='?src=\ref[src];dmake=4'>Trunk</A><BR>
"}

	user.Browse("<HEAD><TITLE>Disposal Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/disposal_pipedispenser/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		var/p_type = text2num(href_list["dmake"])
		var/obj/disposalconstruct/C = new (src.loc)
		switch(p_type)
			if(0)
				C.ptype = 0
			if(1)
				C.ptype = 1
			if(2)
				C.ptype = 2
			if(3)
				C.ptype = 4
			if(4)
				C.ptype = 5

		C.update()

		usr.Browse(null, "window=pipedispenser")
		usr.machine = null
	return

