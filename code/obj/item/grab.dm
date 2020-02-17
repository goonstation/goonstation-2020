//MBC NOTE : we entirely skip over grab level 1. it is not needed but also i am afraid to remove it entirely right now.
/obj/item/grab //TODO : pool grabs
	flags = SUPPRESSATTACK
	var/mob/living/assailant
	var/mob/living/affecting
	var/state = 0 // 0 = passive, 1 aggressive, 2 neck, 3 kill
	var/choke_count = 0
	icon = 'icons/mob/hud_human_new.dmi'
	icon_state = "reinforce"
	name = "grab"
	w_class = 5
	anchored = 1
	var/break_prob = 45
	var/assailant_stam_drain = 30
	var/affecting_stam_drain = 20

	New()
		..()
		SPAWN_DBG(0)
			var/icon/hud_style = hud_style_selection[get_hud_style(src.assailant)]
			if (isicon(hud_style))
				src.icon = hud_style

	disposing()
		if(assailant)	//drop that grab to avoid the sticky behavior
			if (src in assailant.equipped_list())
				if (assailant.equipped() == src)
					assailant.drop_item()
				else
					assailant.hand = !assailant.hand
					assailant.drop_item()
					assailant.hand = !assailant.hand

		if(affecting)
			if (state >= GRAB_NECK)
				if (assailant)
					affecting.layer = assailant.layer
				else
					affecting.layer = initial(affecting.layer)
				affecting.pixel_x = initial(affecting.pixel_x)
				affecting.pixel_y = initial(affecting.pixel_y)
				affecting.set_density(1)

			if (state == GRAB_KILL)
				logTheThing("combat", src.assailant, src.affecting, "releases their choke on %target% after [choke_count] cycles")
			else
				logTheThing("combat", src.assailant, src.affecting, "drops their grab on %target%")
			if (affecting.grabbed_by) affecting.grabbed_by -= src
			affecting = null

		assailant = null
		..()

	dropped()
		qdel(src)

	process(var/mult = 1)
		if (check())
			return

		var/mob/living/carbon/human/H
		if(ishuman(src.affecting))
			H = src.affecting

		if (src.state >= GRAB_NECK)
			if(H) H.remove_stamina(STAMINA_REGEN * 0.5 * mult)
			src.affecting.set_density(0)

		if (src.state == GRAB_KILL)
			//src.affecting.losebreath++
			//if (src.affecting.paralysis < 2)
			//	src.affecting.paralysis = 2
			process_kill(H, mult)

		update_icon()

	attack(atom/target, mob/user)
		if (check())
			return
		if (target == src.affecting)
			attack_self(user)
			return

	attack_hand(mob/user)
		return


	proc/process_kill(var/mob/living/carbon/human/H, mult = 1)
		if(H)
			choke_count += 1 * mult
			H.remove_stamina(STAMINA_REGEN+7 * mult)
			H.stamina_stun()
			if(H.stamina <= -75)
				H.losebreath += (2 * mult)
			else if(H.stamina <= -50)
				H.losebreath += (1 * mult)
			else if(H.stamina <= -33)
				if(prob(33)) H.losebreath += (1 * mult)

	proc/set_affected_loc()
		if (!isturf(src.assailant.loc))
			return

		actions.interrupt(src.affecting, INTERRUPT_ALWAYS)

		var/pxo = 0
		var/pyo = 0
		switch(src.assailant.dir)
			if (EAST)
				pxo = 8
			if (WEST)
				pxo = -8
			if (NORTH)
				pxo = 5
				pyo = 2
			if (SOUTH)
				pxo = -5
				pyo = -1

		if (src.assailant.l_hand == src && pyo != 0) //change pixel position based on which hand the assailant are grabbing with
			pxo *= -1

		src.assailant.pixel_x = 0
		src.assailant.pixel_y = 0
		if (!src.affecting.lying)
			src.affecting.pixel_x = src.assailant.pixel_x + pxo
			src.affecting.pixel_y = src.assailant.pixel_y + pyo
		src.affecting.set_loc(src.assailant.loc)
		src.affecting.layer = src.assailant.layer + (src.assailant.dir == NORTH ? -0.1 : 0.1)
		src.affecting.dir = src.assailant.dir
		src.affecting.set_density(0)

	attack_self(mob/user)
		if (!user)
			return
		if (check())
			return
		switch (src.state)
			if (GRAB_PASSIVE)
				if (user.is_hulk() || prob(75))
					logTheThing("combat", src.assailant, src.affecting, "'s grip upped to aggressive on %target%")
					for(var/mob/O in AIviewers(src.assailant, null))
						O.show_message("<span style=\"color:red\">[src.assailant] has grabbed [src.affecting] aggressively (now hands)!</span>", 1)
					icon_state = "reinforce"
					src.state = GRAB_NECK //used to be '1'. SKIP LEVEL 1
					if (!src.affecting.buckled)
						set_affected_loc()

					user.next_click = world.time + user.combat_click_delay //+ rand(6,11) //this was utterly disgusting, leaving it here in memorial
				else
					for(var/mob/O in AIviewers(src.assailant, null))
						O.show_message("<span style=\"color:red\">[src.assailant] has failed to grab [src.affecting] aggressively!</span>", 1)
					user.next_click = world.time + rand(6,11)
			if (GRAB_AGGRESSIVE)
				if (ishuman(src.affecting))
					var/mob/living/carbon/human/H = src.affecting
					if (H.bioHolder.HasEffect("fat"))
						boutput(src.assailant, "<span style=\"color:blue\">You can't strangle [src.affecting] through all that fat!</span>")
						return
					for (var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
						if (C.body_parts_covered & HEAD)
							boutput(src.assailant, "<span style=\"color:blue\">You have to take off [src.affecting]'s [C.name] first!</span>")
							return
				icon_state = "!reinforce"
				src.state = GRAB_NECK
				if (!src.affecting.buckled)
					set_affected_loc()
				src.assailant.lastattacked = src.affecting
				src.affecting.lastattacker = src.assailant
				src.affecting.lastattackertime = world.time
				logTheThing("combat", src.assailant, src.affecting, "'s grip upped to neck on %target%")
				user.next_click = world.time + user.combat_click_delay
				src.assailant.visible_message("<span style=\"color:red\">[src.assailant] has reinforced [his_or_her(assailant)] grip on [src.affecting] (now neck)!</span>")
			if (GRAB_NECK)
				if (ishuman(src.affecting))
					var/mob/living/carbon/human/H = src.affecting
					for (var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
						if (C.body_parts_covered & HEAD)
							boutput(src.assailant, "<span style=\"color:blue\">You have to take off [src.affecting]'s [C.name] first!</span>")
							return
				actions.start(new/datum/action/bar/icon/strangle_target(src.affecting, src), src.assailant)
				//user.next_click = world.time + 1 //mbc : wow. this makes so much sense as to why i would always toggle killchoke off immediately
				// this is also gross enough to leave in memorial. lol
				user.next_click = world.time + user.combat_click_delay
			if (GRAB_KILL)
				src.state = GRAB_NECK
				logTheThing("combat", src.assailant, src.affecting, "releases their choke on %target% after [choke_count] cycles")
				for (var/mob/O in AIviewers(src.assailant, null))
					O.show_message("<span style=\"color:red\">[src.assailant] has loosened [his_or_her(assailant)] grip on [src.affecting]'s neck!</span>", 1)
				user.next_click = world.time + user.combat_click_delay
		update_icon()

	proc/upgrade_to_kill()
		icon_state = "disarm/kill"
		logTheThing("combat", src.assailant, src.affecting, "chokes %target%")
		choke_count = 0
		for (var/mob/O in AIviewers(src.assailant, null))
			O.show_message("<span style=\"color:red\">[src.assailant] has tightened [his_or_her(assailant)] grip on [src.affecting]'s neck!</span>", 1)
		src.state = GRAB_KILL
		src.assailant.lastattacked = src.affecting
		src.affecting.lastattacker = src.assailant
		src.affecting.lastattackertime = world.time
		if (!src.affecting.buckled)
			set_affected_loc()
		if (src.assailant.bioHolder.HasEffect("fat"))
			src.affecting.unlock_medal("Bear Hug", 1)
		//src.affecting.losebreath++
		//if (src.affecting.paralysis < 2)
		//	src.affecting.paralysis = 2
		//src.affecting.stunned = max(src.affecting.stunned, 3)
		if (ishuman(src.affecting))
			var/mob/living/carbon/human/H = src.affecting
			H.set_stamina(min(0, H.stamina))

	proc/check()
		if(!assailant || !affecting)
			qdel(src)
			return 1

		if(!assailant.is_in_hands(src))
			qdel(src)
			return 1

		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 1

		return 0

	proc/update_icon()
		switch (src.state)
			if (GRAB_PASSIVE)
				icon_state = "reinforce"
			if (GRAB_AGGRESSIVE)
				icon_state = "!reinforce"
			if (GRAB_NECK)
				icon_state = "disarm/kill"
			if (GRAB_KILL)
				icon_state = "disarm/kill1"

	proc/do_resist()
		if (src.state == GRAB_PASSIVE)
			for (var/mob/O in AIviewers(src.affecting, null))
				O.show_message(text("<span style=\"color:red\">[] has broken free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")
			qdel(src)
		else
			if (prob(break_prob))
				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span style=\"color:red\">[] has broken free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")
				qdel(src)
			else
				src.assailant.remove_stamina(assailant_stam_drain)
				src.affecting.remove_stamina(affecting_stam_drain)

				for (var/mob/O in AIviewers(src.affecting, null))
					O.show_message(text("<span style=\"color:red\">[] attempts to break free of []'s grip!</span>", src.affecting, src.assailant), 1, group = "resist")


/datum/action/bar/icon/strangle_target
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED
	id = "strangle_target"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "neck_over"
	var/mob/living/target
	var/obj/item/grab/G

	New(Target, Grab)
		target = Target
		G = Grab
		..()

	onUpdate()
		..()

		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!G || !istype(G) || G.affecting != target || G.state < GRAB_NECK)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(owner && ownerMob && target && G && get_dist(owner, target) <= 1)
			G.upgrade_to_kill()
		else
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt()
		..()
		boutput(owner, "<span style=\"color:red\">You have been interrupted!</span>")
		G = null
		target = null
