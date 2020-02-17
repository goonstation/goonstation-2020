/obj/item/satchel
	name = "satchel"
	desc = "A leather bag. It holds 0/20 items."
	icon = 'icons/obj/items.dmi'
	icon_state = "satchel"
	flags = ONBELT
	w_class = 1
	var/maxitems = 30
	var/list/allowed = list(/obj/item/)
	var/itemstring = "items"

	New()
		src.overlays += image('icons/obj/items.dmi', "satcounter0")
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (!proceed)
			boutput(user, "<span style=\"color:red\">[src] cannot hold that kind of item!</span>")
			return

		if (src.contents.len < src.maxitems)
			user.u_equip(W)
			W.set_loc(src)
			W.dropped()
			boutput(user, "<span style=\"color:blue\">You put [W] in [src].</span>")
			if (src.contents.len == src.maxitems) boutput(user, "<span style=\"color:blue\">[src] is now full!</span>")
			src.satchel_updateicon()
		else boutput(user, "<span style=\"color:red\">[src] is full!</span>")

	attack_self(var/mob/user as mob)
		if (src.contents.len)
			var/turf/T = user.loc
			for (var/obj/item/I in src.contents)
				I.set_loc(T)
			boutput(user, "<span style=\"color:blue\">You empty out [src].</span>")
			src.satchel_updateicon()
		else ..()

	attack_hand(mob/user as mob)
		if (get_dist(user, src) <= 0 && src.contents.len)
			if (user.l_hand == src || user.r_hand == src)
				if  (src.contents.len > 1)
					user.visible_message("<span style=\"color:blue\"><b>[user]</b> rummages through [src].</span>",\
					"<span style=\"color:blue\">You rummage through [src].</span>")
					if (src.contents.len > 20)
						user.visible_message("<span style=\"color:blue\"><b>[user]</b> rummages through [src] fruitlessly.</span>",\
						"<span style=\"color:blue\">You try to rummage through [src], but this satchel is so overloaded it can only burst open!</span>")
						return

					var/list/satchel_contents = list()
					for (var/obj/item/I in src.contents)
						satchel_contents += I
						LAGCHECK(LAG_REALTIME)
					var/obj/item/chosenItem = pick(satchel_contents)
					if (!chosenItem)
						return
					user.visible_message("<span style=\"color:blue\"><b>[usr]</b> takes [chosenItem.name] out of [src].</span>",\
					"<span style=\"color:blue\">You take [chosenItem.name] from [src].</span>")
					user.put_in_hand_or_drop(chosenItem)
		return ..(user)

	verb/search_through()
		set name = "Search Through Contents"
		set src in usr

		var/mob/living/user = usr

		if(!istype(user))
			return

		if (get_dist(user, src) <= 0 && src.contents.len && !user.stat)
			if (user.l_hand == src || user.r_hand == src)
				if (src.contents.len > 1)
					user.visible_message("<span style=\"color:blue\"><b>[user]</b> digs through [src].</span>",\
					"<span style=\"color:blue\">You digs through [src].</span>")
					var/list/satchel_contents = list()
					var/list/has_dupes = list()
					var/temp = ""
					for (var/obj/item/I in src.contents)
						temp = ""
						if (satchel_contents[I.name])
							if (has_dupes[I.name])
								has_dupes[I.name] = has_dupes[I.name] + 1
							else
								has_dupes[I.name] = 2
							temp = "[I.name] ([has_dupes[I.name]])"
							satchel_contents += temp
							satchel_contents[temp] = I
						else
							temp = "[I.name]"
							satchel_contents += temp
							satchel_contents[temp] = I
					var/chosenItem = input("Select an item to pull out.", "Choose Item") as null|anything in satchel_contents
					if (!chosenItem)
						return
					var/obj/item/itemToGive = satchel_contents[chosenItem]
					if (!itemToGive)
						return
					user.visible_message("<span style=\"color:blue\"><b>[usr]</b> takes [itemToGive.name] out of [src].</span>",\
					"<span style=\"color:blue\">You take [itemToGive.name] from [src].</span>")
					user.put_in_hand_or_drop(itemToGive)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(O, check_path))
				proceed = 1
				break
		if (!proceed)
			boutput(user, "<span style=\"color:red\">[src] cannot hold that kind of item!</span>")
			return

		if (src.contents.len < src.maxitems)
			user.visible_message("<span style=\"color:blue\">[user] begins quickly filling [src]!</span>")
			var/staystill = user.loc
			for(var/obj/item/I in view(1,user))
				if (!istype(I, O)) continue
				if (I in user)
					continue
				I.set_loc(src)
				src.satchel_updateicon()
				sleep(2)
				if (user.loc != staystill) break
				if (src.contents.len >= src.maxitems)
					boutput(user, "<span style=\"color:blue\">[src] is now full!</span>")
					break
			boutput(user, "<span style=\"color:blue\">You finish filling [src]!</span>")
		else boutput(user, "<span style=\"color:red\">[src] is full!</span>")

	proc/satchel_updateicon()
		var/perc
		if (src.contents.len > 0 && src.maxitems > 0)
			perc = (src.contents.len / src.maxitems) * 100
		else
			perc = 0
		src.overlays = null
		switch(perc)
			if (-INFINITY to 0)
				src.overlays += image('icons/obj/items.dmi', "satcounter0")
			if (1 to 24)
				src.overlays += image('icons/obj/items.dmi', "satcounter1")
			if (25 to 49)
				src.overlays += image('icons/obj/items.dmi', "satcounter2")
			if (50 to 74)
				src.overlays += image('icons/obj/items.dmi', "satcounter3")
			if (75 to 99)
				src.overlays += image('icons/obj/items.dmi', "satcounter4")
			if (100 to INFINITY)
				src.overlays += image('icons/obj/items.dmi', "satcounter5")

		src.desc = "A leather bag. It holds [src.contents.len]/[src.maxitems] [src.itemstring]."

		signal_event("icon_updated")


/obj/item/satchel/hydro
	name = "produce satchel"
	desc = "A leather bag. It holds 0/50 items of produce."
	icon_state = "hydrosatchel"
	maxitems = 50
	allowed = list(/obj/item/seed,
	/obj/item/plant,
	/obj/item/reagent_containers/food,
	/obj/item/organ,
	/obj/item/clothing/head/butt,
	/obj/item/parts/human_parts/arm,
	/obj/item/parts/human_parts/leg,
	/obj/item/raw_material/cotton)
	itemstring = "items of produce"