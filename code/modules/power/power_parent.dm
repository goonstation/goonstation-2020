/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = 1.0
	var/datum/powernet/powernet = null
	var/netnum = 0
	var/use_datanet = 0		// If set to 1, communicate with other devices over cable network.
	var/directwired = 1		// by default, power machines are connected by a cable in a neighbouring turf
							// if set to 0, requires a 0-X cable on this turf

/obj/machinery/power/New()
	..()
	if (current_state > GAME_STATE_PREGAME)
		SPAWN_DBG (10)
			makepowernets() //Gross, but this should only happen if we are spawned in later, like by mechanics or whoever.

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount)
	if(powernet)
		powernet.newavail += amount

/obj/machinery/power/proc/add_load(var/amount)
	if(powernet)
		powernet.newload += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return powernet.avail-powernet.load
	else
		return 0

/obj/machinery/power/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0


// the powernet datum
// each contiguous network of cables & nodes


// rebuild all power networks from scratch
var/makingpowernets = 0
var/makingpowernetssince = 0
/proc/makepowernets()
	src = null // fuck you
	if (makingpowernets)
		logTheThing("debug", null, null, "makepowernets was called while it was already running! oh no!")
		return

	makingpowernets = 1
	if (ticker)
		makingpowernetssince = ticker.round_elapsed_ticks
	else
		makingpowernetssince = 0

	var/netcount = 0
	powernets = list()

	for(var/obj/cable/PC in allcables)
		PC.netnum = 0
	LAGCHECK(LAG_MED)

	for(var/obj/machinery/power/M in machines)
		if(M.netnum >=0)
			M.netnum = 0
	LAGCHECK(LAG_MED)

	for(var/obj/cable/PC in allcables)
		if(!PC.netnum)
			PC.netnum = ++netcount

			if(Debug) world.log << "Starting mpn at [PC.x],[PC.y] ([PC.d1]/[PC.d2]) #[netcount]"
			powernet_nextlink(PC, PC.netnum)
		LAGCHECK(LAG_MED)

	if(Debug) world.log << "[netcount] powernets found"

	for(var/L = 1 to netcount)
		var/datum/powernet/PN = new()
		//PN.tag = "powernet #[L]"
		powernets += PN
		PN.number = L

	for(var/obj/cable/C in allcables)
		var/datum/powernet/PN = powernets[C.netnum]
		PN.cables += C
		LAGCHECK(LAG_MED)

	for(var/obj/machinery/power/M in machines)
		if(M.netnum<=0)		// APCs have netnum=-1 so they don't count as network nodes directly
			continue

		M.powernet = powernets[M.netnum]
		M.powernet.nodes += M
		if(M.use_datanet)
			M.powernet.data_nodes += M
		LAGCHECK(LAG_MED)

	makingpowernets = 0

/proc/unfuck_makepowernets()
	makingpowernets = 0

/client/proc/fix_powernets()
	set category = "Debug"
	set desc = "Attempts for fix the powernets."
	set name = "Fix powernets"
	unfuck_makepowernets()
	makepowernets()

// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with netnum==0

/proc/power_list(var/turf/T, var/source, var/d, var/unmarked=0)
	var/list/result = list()
	var/fdir = (!d)? 0 : turn(d, 180)	// the opposite direction to d (or 0 if d==0)

	for(var/obj/machinery/power/P in T)
		if(P.netnum < 0)	// exclude APCs
			continue

		if(P.directwired)	// true if this machine covers the whole turf (so can be joined to a cable on neighbour turf)
			if(!unmarked || !P.netnum)
				result += P
		else if(d == 0)		// otherwise, need a 0-X cable on same turf to connect
			if(!unmarked || !P.netnum)
				result += P


	for(var/obj/cable/C in T)
		if(C.d1 == fdir || C.d2 == fdir)
			if(!unmarked || !C.netnum)
				result += C

	result -= source

	return result


/obj/cable/proc/get_connections()

	var/list/res = list()	// this will be a list of all connected power objects

	var/turf/T
	if(!d1)
		T = src.loc		// if d1=0, same turf as src
	else
		T = get_step(src, d1)

	res += power_list(T, src , d1, 1)

	T = get_step(src, d2)

	res += power_list(T, src, d2, 1)

	return res


/obj/machinery/power/proc/get_connections()

	if(!directwired)
		return get_indirect_connections()

	var/list/res = list()
	var/cdir

	for(var/turf/T in orange(1, src))

		cdir = get_dir(T, src)

		for(var/obj/cable/C in T)

			if(C.netnum)
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				res += C

	return res

/obj/machinery/power/proc/get_indirect_connections()

	var/list/res = list()

	for(var/obj/cable/C in src.loc)

		if(C.netnum)
			continue

		if(C.d1 == 0)
			res += C

	return res

/*
/proc/powernet_nextlink(var/obj/O, var/num)

	var/list/P

	//world.log << "start: [O] at [O.x].[O.y]"


	while(1)

		if( istype(O, /obj/cable) )
			var/obj/cable/C = O

			C.netnum = num
			P = C.get_connections()

		else if( istype(O, /obj/machinery/power) )

			var/obj/machinery/power/M = O

			M.netnum = num
			P = M.get_connections()

/*
		if( istype(O, /obj/cable) )
			var/obj/cable/C = O

			P = C.get_connections()

		else if( istype(O, /obj/machinery/power) )

			var/obj/machinery/power/M = O

			P = M.get_connections()
* /
		if(P.len == 0)
			//world.log << "end1"
			return

		O = P[1]


		for(var/L = 2 to P.len)

			powernet_nextlink(P[L], num)

		//world.log << "next: [O] at [O.x].[O.y]"

*/um why is this still a comment
*/
//LummoxJR patch:
/proc/powernet_nextlink(var/obj/O, var/num)
    var/list/P
    var/list/more

    //world.log << "start: [O] at [O.x].[O.y]"

    while(1)
        LAGCHECK(LAG_MED)
        if( istype(O, /obj/cable) )
            var/obj/cable/C = O

            C.netnum = num
            P = C.get_connections()

        else if( istype(O, /obj/machinery/power) )

            var/obj/machinery/power/M = O

            M.netnum = num
            P = M.get_connections()

/*
        if( istype(O, /obj/cable) )
            var/obj/cable/C = O

            P = C.get_connections()

        else if( istype(O, /obj/machinery/power) )

            var/obj/machinery/power/M = O

            P = M.get_connections()
*/
        if(P.len == 0)
            //world.log << "end1"
            if(more && more.len)
                O = more[1]
                more.Cut(1,2)
                continue
            return

        O = P[1]

        //for(var/L = 2 to P.len)
        //  powernet_nextlink(P[L], num)

        // do this instead of calling powernet_nextlink() to avoid recursion
        if(P.len > 1)
            if(!more) more = P.Copy(2)
            else
                var/L = more.len+1
                more += P
                more.Cut(L, L+1)
// cut a powernet at this cable object

/datum/powernet/proc/cut_cable(var/obj/cable/C)

	var/turf/T1 = C.loc
	if(C.d1)
		T1 = get_step(C, C.d1)

	var/turf/T2 = get_step(C, C.d2)

	var/list/P1 = power_list(T1, C, C.d1)	// what joins on to cut cable in dir1

	var/list/P2 = power_list(T2, C, C.d2)	// what joins on to cut cable in dir2

	if(Debug)
		for(var/obj/O in P1)
			world.log << "P1: [O] at [O.x] [O.y] : [istype(O, /obj/cable) ? "[O:d1]/[O:d2]" : null] "
		for(var/obj/O in P2)
			world.log << "P2: [O] at [O.x] [O.y] : [istype(O, /obj/cable) ? "[O:d1]/[O:d2]" : null] "

	if(P1.len == 0 || P2.len ==0)			// if nothing in either list, then the cable was an endpoint
											// no need to rebuild the powernet, just remove cut cable from the list
		cables -= C
		if(Debug) world.log << "Was end of cable"
		return

	// zero the netnum of all cables & nodes in this powernet

	for(var/obj/cable/OC in cables)
		OC.netnum = 0
	for(var/obj/machinery/power/OM in nodes)
		OM.netnum = 0


	// remove the cut cable from the network
	C.netnum = -1
	C.set_loc(null)
	cables -= C

	powernet_nextlink(P1[1], number)		// propagate network from 1st side of cable, using current netnum

	// now test to see if propagation reached to the other side
	// if so, then there's a loop in the network

	var/notlooped = 0
	for(var/obj/O in P2)
		if( istype(O, /obj/machinery/power) )
			var/obj/machinery/power/OM = O
			if(OM.netnum != number)
				notlooped = 1
				break
		else if( istype(O, /obj/cable) )
			var/obj/cable/OC = O
			if(OC.netnum != number)
				notlooped = 1
				break

	if(notlooped)

		// not looped, so make a new powernet

		var/datum/powernet/PN = new()
		//PN.tag = "powernet #[L]"
		powernets += PN
		PN.number = powernets.len

		if(Debug) world.log << "Was not looped: spliting PN#[number] ([cables.len];[nodes.len])"

		for(var/obj/cable/OC in cables)
			if(!OC.netnum)		// non-connected cables will have netnum==0, since they weren't reached by propagation
				OC.netnum = PN.number
				cables -= OC
				PN.cables += OC		// remove from old network & add to new one
			LAGCHECK(LAG_MED)

		for(var/obj/machinery/power/OM in nodes)
			if(!OM.netnum)
				OM.netnum = PN.number
				OM.powernet = PN
				nodes -= OM
				PN.nodes += OM		// same for power machines
				if (OM.use_datanet)	//Don't forget data_nodes! (If relevant)
					data_nodes -= OM
					PN.data_nodes += OM
			LAGCHECK(LAG_MED)

		if(Debug)
			world.log << "Old PN#[number] : ([cables.len];[nodes.len])"
			world.log << "New PN#[PN.number] : ([PN.cables.len];[PN.nodes.len])"

	else
		if(Debug)
			world.log << "Was looped."
		//there is a loop, so nothing to be done
		return

	return

/datum/powernet/proc/reset()
	load = newload
	newload = 0
	avail = newavail
	newavail = 0

	viewload = 0.8*viewload + 0.2*load

	viewload = round(viewload)

	var/numapc = 0

	if (!nodes)
		nodes = list()

	for(var/obj/machinery/power/terminal/term in nodes)
		if( istype( term.master, /obj/machinery/power/apc ) )
			numapc++

	if(numapc)
		perapc = avail/numapc

	netexcess = avail - load

	if( netexcess > 100)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used