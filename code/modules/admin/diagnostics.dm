/client/proc
	map_debug_panel()
		set category = "Debug"

		var/area_txt = "<B>APC LOCATION REPORT</B><HR>"
		var/apc_count = 0
		var/list/apcs = new()
		for(var/area/area in world)
			if (!area.requires_power)
				continue

			for(var/obj/machinery/power/apc/current_apc in area)
				if (!apcs.Find(current_apc)) apcs += current_apc

			apc_count = apcs.len
			if (apc_count != 1)
				area_txt += "[area.name] [area.type] has [apc_count] APCs.<br>"
			apcs.len = 0

			LAGCHECK(LAG_LOW)

		usr.Browse(area_txt,"window=mapdebugpanel")


	general_report()
		set category = "Debug"

		if(!processScheduler)
			usr << alert("Process Scheduler not found.")

		var/mobs = 0
		for(var/mob/M in mobs)
			mobs++

		var/output = {"<B>GENERAL SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Machines:</B> [machines.len + atmos_machines.len]<BR>
<B># of Pipe Networks:</B> [pipe_networks.len]<BR>
<B># of Processing Items:</B> [processing_items.len]<BR>
<B># of Power Nets:</B> [powernets.len]<BR>
<B># of Mobs:</B> [mobs]<BR>
"}

		usr.Browse(output,"window=generalreport")

	air_report()
		set category = "Debug"

		if(!processScheduler || !air_master)
			alert(usr,"processScheduler or air_master not found.","Air Report")
			return 0

		var/active_groups = 0
		var/inactive_groups = 0
		var/active_tiles = 0
		for(var/datum/air_group/group in air_master.air_groups)
			if(group.group_processing)
				active_groups++
			else
				inactive_groups++
				active_tiles += group.members.len

		var/hotspots = 0
		for(var/obj/hotspot/hotspot in world)
			hotspots++
			LAGCHECK(LAG_LOW)

		var/output = {"<B>AIR SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Groups:</B> [air_master.air_groups.len]<BR>
---- <I>Active:</I> [active_groups]<BR>
---- <I>Inactive:</I> [inactive_groups]<BR>
-------- <I>Tiles:</I> [active_tiles]<BR>
<B># of Active Singletons:</B> [air_master.active_singletons.len]<BR>
<BR>
<B>Total # of Gas Mixtures In Existence: </B>[total_gas_mixtures]<BR>
<B>Special Processing Data</B><BR>
<B>Hotspot Processing:</B> [hotspots]<BR>
<B>High Temperature Processing:</B> [air_master.active_super_conductivity.len]<BR>
<B>High Pressure Processing:</B> [air_master.high_pressure_delta.len] (not yet implemented)<BR>
<BR>
<B>Geometry Processing Data</B><BR>
<B>Group Rebuild:</B> [air_master.groups_to_rebuild.len]<BR>
<B>Tile Update:</B> [air_master.tiles_to_update.len]<BR>
[air_histogram()]
"}

		usr.Browse(output,"window=airreport")

	air_histogram()

		var/html = "<pre>"
		var/list/ghistogram = new
		var/list/ughistogram = new
		var/p

		for(var/datum/air_group/g in air_master.air_groups)
			if (g.group_processing)
				for(var/turf/simulated/member in g.members)
					p = round(max(-1, member.air.return_pressure()), 10)/10 + 1
					if (p > ghistogram.len)
						ghistogram.len = p
					ghistogram[p]++
			else
				for(var/turf/simulated/member in g.members)
					p = round(max(-1, member.air.return_pressure()), 10)/10 + 1
					if (p > ughistogram.len)
						ughistogram.len = p
					ughistogram[p]++

		html += "Group processing tiles pressure histogram data:\n"
		for(var/i=1,i<=ghistogram.len,i++)
			html += "[10*(i-1)]\t\t[ghistogram[i]]\n"
		html += "Non-group processing tiles pressure histogram data:\n"
		for(var/i=1,i<=ughistogram.len,i++)
			html += "[10*(i-1)]\t\t[ughistogram[i]]\n"
		return html

	air_status(turf/target as turf)
		set category = "Debug"
		set name = "Air Status"

		if(!isturf(target))
			return

		var/datum/gas_mixture/GM = target.return_air()
		var/burning = 0
		if(istype(target, /turf/simulated))
			var/turf/simulated/T = target
			if(T.active_hotspot)
				burning = 1

		boutput(usr, "<span style=\"color:blue\">@[target.x],[target.y] ([GM.group_multiplier]): O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] t:[GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("<span style=\"color:red\">BURNING</span>"):(null)]</span>")

		if(GM.trace_gases)
			for(var/datum/gas/trace_gas in GM.trace_gases)
				boutput(usr, "[trace_gas.type]: [trace_gas.moles]")

	fix_next_move()
		set category = "Debug"
		set name = "Press this if everybody freezes up"
		var/largest_click_time = 0
		var/mob/largest_click_mob = null
		if (disable_next_click)
			boutput(usr, "<span style=\"color:red\">next_click is disabled and therefore so is this command!</span>")
			return
		for(var/mob/M in mobs)
			if(!M.client)
				continue
			if(M.next_click >= largest_click_time)
				largest_click_mob = M
				if(M.next_click > world.time)
					largest_click_time = M.next_click - world.time
				else
					largest_click_time = 0
			logTheThing("admin", M, null, "lastDblClick = [M.next_click]  world.time = [world.time]")
			logTheThing("diary", M, null, "lastDblClick = [M.next_click]  world.time = [world.time]", "admin")
			M.next_click = 0
		message_admins("[key_name(largest_click_mob, 1)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!")
		message_admins("world.time = [world.time]")
		return

	debug_profiler()
		set category = "Debug"
		set name = "Open Profiler"

		admin_only
		world.SetConfig( "APP/admin", src.key, "role=admin" )
		input( src, "Enter '.debug profile' in the next command box. Blame BYOND.", "BYONDSucks", ".debug profile" )
		winset( usr, null, "command=.command" )

/datum/infooverlay
	var/help = "Huh."
	var/restricted = 0//if only coders+ can use it
	proc/GetInfo(var/turf/theTurf, var/image/theImage)
		//ono
	teleblocked/help = "Red tiles are ones that are teleblocked, green ones can be teleported to."
	teleblocked/GetInfo(var/turf/theTurf, var/image/theImage)
		if(1)
			theImage.desc = "This is disabled cus its SLOW."
			return
		if( theTurf in telesci )
			theImage.color = "#0f0"
			return

		if( theTurf.loc:teleport_blocked || isrestrictedz(theTurf.z) )
			theImage.color = "#f00"
			return
		for (var/obj/machinery/telejam/T)
			if (!T.active || T.z != theTurf.z)
				continue
			var/r = get_dist(T, theTurf)
			if (r > T.range)
				continue
			theImage.color = "#f00"
			return
		for (var/obj/item/device/flockblocker/F)
			if (!F.active || F.z != theTurf.z)
				continue
			var/r = get_dist(F, theTurf)
			if (r > F.range)
				continue
			theImage.color = "#f00"
			return
		for (var/obj/blob/nucleus/N in range(theTurf, 3))
			theImage.color = "#f00"
			return
		theImage.color = "#0f0"
	blowout/help = "Green tiles are safe from irradiation, red tiles are ones that are not."
	blowout/GetInfo(var/turf/theTurf, var/image/theImage)
		if(theTurf.loc:do_not_irradiate)
			theImage.color = "#0f0"
		else
			theImage.color = "#f00"
	areas/help = "Differentiates between different areas. Also gives you area names because thats cool and stuff."
	areas/GetInfo(var/turf/theTurf, var/image/theImage)
		if(!theTurf.loc:gencolor)
			theTurf.loc:gencolor = rgb( rand(1,255),rand(1,255),rand(1,255) )
		theImage.desc = "Area: [theTurf.loc:name]<br/>Type: [theTurf.loc:type]"
		theImage.color = theTurf.loc:gencolor
		theImage.mouse_opacity = 1
	atmos_air/help = "Debug atmospherics and contents and stuffs"
	atmos_air/GetInfo(var/turf/theTurf, var/image/theImage)
		var/turf/simulated/sim = theTurf
		theImage.mouse_opacity = 1
		if(istype(sim, /turf/simulated))//byondood
			var/datum/air_group/group = sim.parent
			if(group)
				if(!group.gencolor)
					group.gencolor = rgb( rand(1,255),rand(1,255),rand(1,255) )
				theImage.color = group.gencolor
				theImage.desc = "Group \ref[group]<br>O2=[group.air.oxygen]<br/>Nitrogen=[group.air.nitrogen]<br/>CO2=[group.air.carbon_dioxide]<br/>Plasma=[group.air.toxins]<br/>Temperature=[group.air.temperature]<br/>Spaced=[group.spaced]"
				if (group.spaced) theImage.overlays += image('icons/misc/air_debug.dmi', icon_state = "spaced")
				var/list/borders_space = list()
				for(var/turf/spaceses in group.space_borders)
					if(get_dist(spaceses, theTurf) == 1)
						var/dir = get_dir(theTurf, spaceses)
						if((dir & (dir-1)) == 0)
							if(dir & NORTH) borders_space[++borders_space.len] = "NORTH"
							if(dir & SOUTH) borders_space[++borders_space.len] = "SOUTH"
							if(dir & EAST) borders_space[++borders_space.len] = "EAST"
							if(dir & WEST) borders_space[++borders_space.len] = "WEST"
							var/image/airrowe = image('icons/misc/air_debug.dmi', icon_state = "space", dir = dir)
							airrowe.appearance_flags = RESET_COLOR
							theImage.overlays += airrowe
				if(borders_space.len)
					theImage.desc += "<br/>(borders space to the [borders_space.Join(" ")])"
			else
				theImage.color = "#ffffff"
				theImage.desc = "No Atmos Group<br/>O2=[sim.oxygen]<br/>Nitrogen=[sim.nitrogen]<br/>CO2=[sim.carbon_dioxide]<br/>Plasma=[sim.toxins]<br/>Temperature=[sim.temperature]"
		else
			theImage.desc = "-unsimulated-"
			theImage.color = "#202020"
	artists/help = "Shows you the artists of the wonderful writing thats' been written on the station."
	artists/GetInfo(var/turf/theTurf, var/image/theImage)
		var/list/built = list()
		for(var/obj/decal/cleanable/writing/arte in theTurf)
			built += "[arte.icon_state] artpiece by [arte.artist]"
		if(built.len)
			theTurf.color = "#7f0000"
		theImage.desc = built.Join("<br/>")

/client/var/list/infoOverlayImages
/client/var/datum/infooverlay/activeOverlay
/obj/overlay/debugoverlay
	mouse_opacity = 0
	icon = 'icons/effects/white.dmi'
	plane = PLANE_HUD - 1
/client/proc/RenderOverlay()
	var/width
	var/height
	if(istext( view ))
		var/split = splittext(view, "x")
		width = text2num(split[1])+1
		height = text2num(split[2])+1
	else
		width = view*2+1
		height = view*2+1
	for(var/x = 1, x<=width , x++)
		for(var/y = 1, y<=height, y++)
			var/turf/t = locate( eye:x + x - width/2 - 1, eye:y + y - height/2 - 1, eye:z )
			var/image/overlay = infoOverlayImages[ "[x]-[y]" ]
			overlay.loc = t
			overlay.mouse_opacity = 0
			overlay.override = 0
			//overlay.plane = 100
			//overlay.layer = 100
			overlay.overlays = list()
			if(!t)
				overlay.icon_state = "notwhite"
				overlay.alpha = 0
			else
				overlay.icon_state = ""
				activeOverlay.GetInfo( t, overlay )
				overlay.alpha = 64
/client/proc/GenerateOverlay()
	var/width = view
	var/height = view
		
	if(istext( view ))
		var/split = splittext(view, "x")
		width = text2num(split[1])/2
		height = text2num(split[2])/2
	if( !infoOverlayImages ) infoOverlayImages = list()
	for(var/x = 1, x<=width*2+1, x++)
		for(var/y = 1, y<=height*2+1, y++)
			if(!infoOverlayImages[ "[x]-[y]" ])
				var/image/overlay = new('icons/effects/white.dmi')
				infoOverlayImages[ "[x]-[y]" ] = overlay
				src.images += overlay
/client/proc/SetInfoOverlay( )
	set name = "Debug Overlay"
	set category = "Debug"
	admin_only
	var/name = input("Choose an overlay") in (childrentypesof( /datum/infooverlay ) + "Remove")
	if(!name || name == "Remove")
		if(infoOverlayImages)
			for(var/img in infoOverlayImages)
				img = infoOverlayImages[img]//shhh
				screen -= img
				img:loc = null
				qdel(img)
			infoOverlayImages = list()
		activeOverlay = null
		qdel(activeOverlay)
	else
		activeOverlay = new name()
		boutput( src, "<span style='color:blue'>[activeOverlay.help]</span>" )
		GenerateOverlay()
		RenderOverlay()
/turf
	MouseEntered(location, control, params)
		if(usr.client.activeOverlay)
			var/list/lparams = params2list(params)
			var/offs = splittext(lparams["screen-loc"], ",")

			var/x = text2num(splittext(offs[1], ":")[1])+1
			var/y = text2num(splittext(offs[2], ":")[1])+1
			var/image/im = usr.client.infoOverlayImages["[x]-[y]"]
			if(im && im.desc)
				usr.client.tooltipHolder.transient.show(src, list(
					"params" = params,
					"title" = "Diagnostics",
					"content" = (im.desc)
				))
		else
			.=..()
	MouseExited()
		if(usr.client.activeOverlay)
			usr.client.tooltipHolder.transient.hide()
		else
			.=..()
/mob/OnMove()

	if(client && client.activeOverlay)
		client.GenerateOverlay()
		client.RenderOverlay()
	.=..()
