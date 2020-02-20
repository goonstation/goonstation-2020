
/obj/item/sticker
	name = "sticker"
	desc = "You stick it on something, then that thing is even better, because it has a little sparkly unicorn stuck to it, or whatever."
	flags = FPRINT | TABLEPASS
	event_handler_flags = HANDLE_STICKER | USE_FLUID_ENTER
	icon = 'icons/misc/stickers.dmi'
	icon_state = "bounds"
	w_class = 1.0
	force = 0
	throwforce = 0
	var/active = 0
	var/overlay_key
	var/atom/attached
	var/list/random_icons = list()

	New()
		if (islist(src.random_icons) && src.random_icons.len)
			src.icon_state = pick(src.random_icons)
		pixel_y = rand(-8, 8)
		pixel_x = rand(-8, 8)

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		if (!A)
			return
		if (isarea(A) || istype(A, /obj/item/item_box))
			return
		user.tri_message("<b>[user]</b> sticks [src] to [A]!",\
		user, "You stick [src] to [user == A ? "yourself" : "[A]"]!",\
		A, "[user == A ? "You stick" : "<b>[user]</b> sticks"] [src] to you[user == A ? "rself" : null]!")
		var/pox = src.pixel_x
		var/poy = src.pixel_y
		DEBUG_MESSAGE("pox [pox] poy [poy]")
		if (params)
			if (islist(params) && params["icon-y"] && params["icon-x"])
				pox = text2num(params["icon-x"]) - 16 //round(A.bound_width/2)
				poy = text2num(params["icon-y"]) - 16 //round(A.bound_height/2)
				DEBUG_MESSAGE("pox [pox] poy [poy]")
		src.stick_to(A, pox, poy)
		user.u_equip(src)
		return 1

	proc/stick_to(var/atom/A, var/pox, var/poy)
		var/image/sticker = image('icons/misc/stickers.dmi', src.icon_state)
		//sticker.layer = //EFFECTS_LAYER_BASE // I swear to fuckin god stop being under CLOTHES you SHIT
		sticker.layer = A.layer + 1 //Do this instead so the stickers don't show over bushes and stuff.
		sticker.icon_state = src.icon_state
		sticker.appearance_flags = RESET_COLOR

		//pox = CLAMP(-round(A.bound_width/2), pox, round(A.bound_width/2))
		//poy = CLAMP(-round(A.bound_height/2), pox, round(A.bound_height/2))
		sticker.pixel_x = pox
		sticker.pixel_y = poy
		overlay_key = "sticker[world.timeofday]"
		attached = A
		A.UpdateOverlays(sticker, overlay_key)
		//	qdel(src) //Don't delete stickers when applied - remove them later through fire or acetone!
		src.active = 1
		src.loc = A
		src.invisibility = 101

		playsound(get_turf(src), 'sound/items/sticker.ogg', 50, 1)

	throw_impact(atom/A)
		..()
		if (prob(50))
			A.visible_message("<span style=\"color:red\">[src] lands on [A] sticky side down!</span>")
			src.stick_to(A,rand(-5,5),rand(-8,8))

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if((temperature > T0C+120) && active)
			qdel(src)

	//Coded this for acetone, but then I realized that it would let people check if they were stuck with a spysticker or not.
	//Going to leave this here just in case, but it's not used for anything right now.
	proc/fall_off()
		if (!active) return
		if (istype(attached,/turf))
			src.loc = attached
		else
			src.loc = attached.loc
		attached.ClearSpecificOverlays(overlay_key)
		active = 0
		overlay_key = 0
		src.invisibility = 0
		attached.visible_message("<span style=\"color:red\"><b>[src]</b> un-sticks from [attached] and falls to the floor!</span>")
		attached = 0

	dispose()
		if (attached)
			if (active)
				attached.ClearSpecificOverlays(overlay_key)
			attached.visible_message("<span style=\"color:red\"><b>[src]</b> is destroyed!</span>")

	attack()
		return

/obj/item/sticker/gold_star
	name = "gold star sticker"
	desc = "For when you wanna show someone that they've really accomplished something great."
	icon_state = "gold_star"

/obj/item/sticker/banana
	name = "banana sticker"
	desc = "Wait, can't you just buy your own?"
	icon_state = "banana"
	random_icons = list("banana", "bananas")

/obj/item/sticker/clover
	name = "clover sticker"
	icon_state = "clover"

/obj/item/sticker/umbrella
	name = "umbrella sticker"
	icon_state = "umbrella"

/obj/item/sticker/skull
	name = "skull sticker"
	icon_state = "skull"

/obj/item/sticker/no
	name = "\"no\" sticker"
	icon_state = "no"

/obj/item/sticker/left_arrow
	name = "left arrow sticker"
	icon_state = "Larrow"

/obj/item/sticker/right_arrow
	name = "right arrow sticker"
	icon_state = "Rarrow"

/obj/item/sticker/heart
	name = "heart sticker"
	icon_state = "heart"
	random_icons = list("heart", "rheart")

/obj/item/sticker/moon
	name = "moon sticker"
	icon_state = "moon"

/obj/item/sticker/smile
	name = "smile sticker"
	icon_state = "smile"
	random_icons = list("smile", "smile2")

/obj/item/sticker/frown
	name = "frown sticker"
	icon_state = "frown"
	random_icons = list("frown", "frown2")

/obj/item/sticker/balloon
	name = "red balloon sticker"
	icon_state = "balloon"

/obj/item/sticker/rainbow
	name = "rainbow sticker"
	icon_state = "rainbow"

/obj/item/sticker/horseshoe
	name = "horseshoe sticker"
	icon_state = "horseshoe"

/obj/item/sticker/bee
	name = "bee sticker"
	icon_state = "bee"

/obj/item/sticker/xmas_ornament
	name = "ornament"
	desc = "A Spacemas ornament!"
	icon_state = "ornament1"

/obj/item/sticker/xmas_ornament/green
	icon_state = "ornament2"

/obj/item/sticker/xmas_ornament/snowflake
	name = "snowflake ornament"
	icon_state = "snowflake"

/obj/item/sticker/xmas_ornament/holly
	name = "holly ornament"
	icon_state = "holly"

/obj/item/sticker/ribbon
	name = "award ribbon"
	desc = "You're an award winner! You came in, uh... Well it looks like this doesn't say what place you came in, or what it's for. That's weird. But hey, it's an award for something! Maybe it was for being the #1 Farter, or maybe the #8 Ukelele Soloist. Truly, with an award as vague as this, you could be anything!"
	icon_state = "no_place"
	var/placement = "Award-Winning"

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		..()
		if (!A)
			return
		if (!src.placement)
			return
		A.name_prefix(src.placement)
		A.UpdateName()

	first_place
		name = "\improper 1st place award ribbon"
		desc = "You're an award winner! First place! For what? Doesn't matter! You're #1! Woo!"
		icon_state = "1st_place"
		placement = "1st-Place"

	second_place
		name = "\improper 2nd place award ribbon"
		desc = "It's like you intend to be a disappointment and a failure. Were you even trying at all?"
		icon_state = "2nd_place"
		placement = "2nd-Place"

	third_place
		name = "\improper 3rd place award ribbon"
		desc = "Not best, not second best, but still worth mentioning, kinda. That's you! Congrats!"
		icon_state = "3rd_place"
		placement = "3rd-Place"

	participant
		name = "participation ribbon"
		desc = "You showed up, which is really the hardest part. With accreditations like this award ribbon, you've proven you can do anything."
		placement = "Participant"

	voter
		name = "\improper 'I voted' sticker"
		desc = "You voted! That means whatever terrible outcome your vote leads to is <em>your</em> fault. But hey, at least you got a sticker for it!"
		icon_state = "gold_star"
		placement = "Voter"

//	-----------------------------------
//			v Spy Sticker Stuff v
//  -----------------------------------

/obj/item/sticker/spy
	name = "gold star sticker"
	icon_state = "gold_star"
	desc = "This sticker contains a tiny radio transmitter that handles audio and video. Closer inspection reveals an interface on the back with camera, radio, and visual options."
	open_to_sound = 1

	var/has_radio = 1 // just in case you wanted video-only ones, I guess?
	var/obj/item/device/radio/spy/radio = null
	var/radio_path = null

	var/has_camera = 1 // the detective's stickers don't get a camera
	var/obj/machinery/camera/camera = null
	var/camera_tag = "sticker"
	var/camera_network = "stickers"
	var/tv_network = "Zeta"
	var/sec_network = "SS13"

	var/has_selectable_skin = 1 //
	var/list/skins = list("gold_star" = "gold star", "banana", "umbrella", "heart", "clover", "skull", "Larrow" = "left arrow",
	"Rarrow" = "right arrow", "no" = "\"no\"", "moon", "smile", "rainbow", "frown", "balloon", "horseshoe", "bee")

	var/HTML = null

	New()
		..()
		if (islist(src.skins))
			var/new_skin = pick(src.skins)
			var/new_name = istext(src.skins[new_skin]) ? src.skins[new_skin] : null
			src.set_type(new_skin, new_name)
		if (!src.has_selectable_skin)
			src.verbs -= /obj/item/sticker/spy/verb/set_sticker_type

		if (has_camera)
			src.camera = new /obj/machinery/camera (src)
			src.camera.c_tag = src.camera_tag
			src.camera.network = src.camera_network
			src.camera.camera_status = 0
			src.camera_tag = src.name
		else
			src.verbs -= /obj/item/sticker/spy/verb/set_internal_camera

		if (src.has_radio)
			if (ispath(src.radio_path))
				src.radio = new src.radio_path (src)
			else
				src.radio = new /obj/item/device/radio/spy (src)
			SPAWN_DBG(1 DECI SECOND)
				src.radio.broadcasting = 0
				//src.radio.listening = 0
		else
			src.verbs -= /obj/item/sticker/spy/verb/set_internal_radio

	fall_off()
		if (src.radio)
			src.loc.open_to_sound = 0
		if (src.camera)
			src.camera.camera_status = 0
			src.camera.c_tag = src.camera_tag
		..()

	dispose()
		if ((active) && (attached != null))
			attached.open_to_sound = 0
		if (src.camera)
			qdel(src.camera)
		if (src.radio)
			qdel(src.radio)
		..()

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		if (src.camera)
			src.camera.c_tag = "[src.camera_tag] ([A.name])"
			src.camera.camera_status = 1.0
			src.camera.updateCoverage()
		if (src.radio)
			src.radio.invisibility = 101
		logTheThing("combat", user, A, "places a spy sticker on %target% at [log_loc(user)].")

		..()

		if (istype(A, /turf/simulated/wall) || istype(A, /turf/unsimulated/wall))
			src.loc = get_turf(user) //If sticking to a wall, just set the loc to the user loc. Otherwise the spycam would be able to see through walls.

		if (src.radio)
			src.loc.open_to_sound = 1


	proc/generate_html()
		src.HTML = {"<TT>Camera Broadcast Network:<BR>
		[src.camera.network == src.camera_network ? "Spy Monitor (ACTIVE)" : "<A href='byond://?src=\ref[src];change_setting=spynetwork'>Spy Monitor</A>"]<BR>
		[src.camera.network == src.sec_network ? "Security (ACTIVE)" : "<A href='byond://?src=\ref[src];change_setting=secnetwork'>Security</A>"]<BR>
		[src.camera.network == src.tv_network ? "Public Television Broadcast (ACTIVE)" : "<A href='byond://?src=\ref[src];change_setting=tvnetwork'>Public Television Broadcast</A>"]<BR>"}

	verb/set_internal_radio()
		if (!ishuman(usr) || !src.radio)
			return
		src.radio.attack_self(usr)

	verb/set_internal_camera()
		if (!ishuman(usr) || !src.camera)
			return
		usr.machine = src.camera
		if (!src.HTML)
			src.generate_html()
		usr.Browse(src.HTML, "window=sticker_internal_camera;title=Sticker Internal Camera")
		return

	Topic(href, href_list)
		if (!usr || usr.stat)
			return

		if ((get_dist(src, usr) <= 1) || (usr.loc == src.loc))
			usr.machine = src
			switch (href_list["change_setting"])
				if ("spynetwork")
					if (src.camera)
						src.camera.network = src.camera_network
						src.generate_html()
						src.set_internal_camera(usr)
				if ("secnetwork")
					if (src.camera)
						src.camera.network = src.sec_network
						src.generate_html()
						src.set_internal_camera(usr)
				if ("tvnetwork")
					if (src.camera)
						src.camera.network = src.tv_network
						src.generate_html()
						src.set_internal_camera(usr)

		else
			usr.Browse(null, "window=radio")
			usr.Browse(null, "window=sticker_internal_camera")

	verb/set_sticker_type()
		if (!ishuman(usr) || !islist(src.skins))
			return
		var/new_skin = input(usr,"Select Sticker Type:","Spy Sticker",null) as null|anything in src.skins
		if (!new_skin)
			return
		var/new_name = istext(src.skins[new_skin]) ? src.skins[new_skin] : null
		src.set_type(new_skin, new_name)

	proc/set_type(var/new_skin, var/new_name)
		if (!new_skin)
			return
		src.icon_state = new_skin
		if (new_name)
			src.name = "[new_name] sticker"
		else
			src.name = "[new_skin] sticker"

/obj/item/sticker/spy/radio_only
	desc = "This sticker contains a tiny radio transmitter that handles audio. Closer inspection reveals an interface on the back with radio options."
	has_camera = 0
	has_selectable_skin = 0

/obj/item/sticker/spy/radio_only/sec_only
	desc = "This sticker contains a tiny radio transmitter that handles audio. Closer inspection reveals that the frequency is locked to the Security channel."
	radio_path = /obj/item/device/radio/spy/sec_only

/obj/item/sticker/spy/camera_only
	desc = "This sticker contains a tiny radio transmitter that handles video. Closer inspection reveals an interface on the back with camera options."
	has_radio = 0
	has_selectable_skin = 0

/obj/item/device/camera_viewer/sticker
	name = "Camera monitor"
	desc = "A portable video monitor connected to a network of spy cameras."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = 2.0
	network = "stickers"

/obj/item/storage/box/spy_sticker_kit
	name = "spy sticker kit"
	desc = "Includes everything you need to spy on your unsuspecting co-workers!"
	spawn_contents = list(/obj/item/sticker/spy = 5,
	/obj/item/device/camera_viewer/sticker,
	/obj/item/device/radio/headset)

/obj/item/storage/box/spy_sticker_kit/radio_only
	spawn_contents = list(/obj/item/sticker/spy/radio_only = 5,
	/obj/item/device/radio/headset)

/obj/item/storage/box/spy_sticker_kit/radio_only/detective
	spawn_contents = list(/obj/item/sticker/spy/radio_only/sec_only = 6,
	/obj/item/device/radio/headset/security)

/obj/item/storage/box/spy_sticker_kit/camera_only
	spawn_contents = list(/obj/item/sticker/spy/camera_only = 6,
	/obj/item/device/camera_viewer/sticker)

/obj/item/device/radio/spy
	name = "spy radio"
	desc = "Spy radio housed in a sticker. Wait, how are you reading this?"

/obj/item/device/radio/spy/sec_only
	locked_frequency = 1
	frequency = R_FREQ_SECURITY
	device_color = RADIOC_SECURITY
