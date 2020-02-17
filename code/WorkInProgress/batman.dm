
// 4 arfur
// xoxo procitizen


/obj/item/clothing/suit/armor/batman/equipped(var/mob/user)
	user.verbs += /client/proc/batsmoke
	user.verbs += /client/proc/batarang
	user.verbs += /mob/proc/batkick
	user.verbs += /mob/proc/batrevive
	user.verbs += /mob/proc/batattack
	user.verbs += /mob/proc/batspinkick
	user.verbs += /mob/proc/batspin
	user.verbs += /mob/proc/batdropkick

/obj/item/clothing/suit/armor/batman/unequipped(var/mob/user)
	user.verbs -= /client/proc/batsmoke
	user.verbs -= /client/proc/batarang
	user.verbs -= /mob/proc/batkick
	user.verbs -= /mob/proc/batrevive
	user.verbs -= /mob/proc/batattack
	user.verbs -= /mob/proc/batspinkick
	user.verbs -= /mob/proc/batspin
	user.verbs -= /mob/proc/batdropkick

/client/proc/batsmoke()
	set category = "Batman"
	set name = "Batsmoke \[Support]"

	var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()

/client/proc/batarang(mob/T as mob in oview())
	set category = "Batman"
	set name = "Batarang \[Combat]"

	for(var/mob/O in viewers(usr, null))
		O.show_message(text("<span style=\"color:red\">[] tosses a batarang at []!</span>", usr, T), 1)
	var/obj/overlay/A = new /obj/overlay( usr.loc )
	A.icon_state = "batarang"
	A.icon = 'icons/effects/effects.dmi'
	A.name = "a batarang"
	A.anchored = 0
	A.set_density(0)
	var/i
	for(i=0, i<100, i++)
		step_to(A,T,0)
		if (get_dist(A,T) <= 1)
			T.weakened += 5
			T.stunned += 5
			for(var/mob/O in viewers(T, null))
				O.show_message(text("<span style=\"color:red\">[] was struck by the batarang!</span>", T), 1)
			qdel(A)
		sleep(2)
	qdel(A)
	return

/mob/proc/batkick(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Kick \[Combat]"
	set desc = "A powerful stunning kick, sending people flying across the room"

	SPAWN_DBG(0)
		if(T)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span style=\"color:red\"><B>[] powerfully kicks []!</B></span>", usr, T), 1)
			T.weakened += 6
			step_away(T,usr,15)
			sleep(1)
			step_away(T,usr,15)
			sleep(1)
			step_away(T,usr,15)
			playsound(T.loc, "swing_hit", 25, 1, -1)

/mob/proc/batrevive()
	set category = "Batman"
	set name = "Recover \[Support]"
	set desc = "Unstuns you"

	if(!usr.weakened)
		usr.getStatusDuration("stunned") = 0
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] suddenly recovers!</B></span>", usr), 1)
	else
		usr.delStatus("weakened")
		usr.getStatusDuration("stunned") = 0
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] suddenly jumps up!</B></span>", usr), 1)

/mob/proc/batattack(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Punch \[Combat]"
	set desc = "Attack, but Batman-like ok"

	if(usr.stat)
		boutput(usr, "<span style=\"color:red\">Not when you're incapped!</span>")
		return
	SPAWN_DBG(0)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] punches []!</B></span>", usr, T), 1)
		var/zone = "chest"
		if(usr.zone_sel)
			zone = usr.zone_sel.selecting
		if ((zone in list( "eyes", "mouth" )))
			zone = "head"
		T.TakeDamage(zone, 4, 0)
		T.stunned += 1
		var/image/I = image('icons/effects/effects.dmi',prob(50) ? "batpow" : "batwham")
		T.overlays += I
		SPAWN_DBG(50) T.overlays -= I
		T.updatehealth()

/mob/proc/batspinkick(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Batkick \[Finisher]"
	set desc = "A spinning kick that drops motherfuckers to the CURB"

	var/image/I = image('icons/effects/effects.dmi',"batpow")
	var/image/R = image('icons/effects/effects.dmi', "batwham")
	if(usr.stat)
		boutput(usr, "<span style=\"color:red\">Not when you're incapped!</span>")
		return
	SPAWN_DBG(0)
		T.transforming = 1
		src.transforming = 1
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] leaps in the air, shocking []!</B></span>", usr, T), 1)
		for(var/i = 0, i < 5, i++)
			usr.pixel_y += 4
			sleep(2)
		sleep(10)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] begins kicking [] in the face rapidly!</B></span>", usr, T), 1)
		for(var/i = 0, i < 5, i++)
			usr.dir = NORTH
			T.TakeDamage("head", 4, 0)
			T.updatehealth()
			T.overlays -= R
			T.overlays += I
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span style=\"color:red\"><B>[] kicks [] in the face!</B></span>", usr, T), 1)
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(1)
			usr.dir = EAST
			T.TakeDamage("head", 4, 0)
			T.updatehealth()
			T.overlays -= I
			T.overlays += R
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span style=\"color:red\"><B>[] kicks [] in the face!</B></span>", usr, T), 1)
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(1)
			usr.dir = SOUTH
			T.TakeDamage("head", 4, 0)
			T.updatehealth()
			T.overlays -= R
			T.overlays += I
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span style=\"color:red\"><B>[] kicks [] in the face!</B></span>", usr, T), 1)
			playsound(T.loc, "swing_hit", 25, 1, -1)
			sleep(1)
			usr.dir = WEST
			T.TakeDamage("head", 4, 0)
			T.updatehealth()
			T.overlays -= I
			T.overlays += R
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span style=\"color:red\"><B>[] kicks [] in the face!</B></span>", usr, T), 1)
			playsound(T.loc, "swing_hit", 25, 1, -1)
		usr.dir = get_dir(usr, T)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] stares deeply at []!</B></span>", usr, T), 1)
		sleep(50)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] unleashes a tremendous kick to the jaw towards []!</B></span>", usr, T), 1)
		playsound(T.loc, "swing_hit", 25, 1, -1)
		flick("e_flash", T.flash)
		T.transforming = 0
		T.weakened += 6
		step_away(T,usr,15)
		sleep(1)
		step_away(T,usr,15)
		sleep(1)
		step_away(T,usr,15)
		sleep(1)
		step_away(T,usr,15)
		sleep(1)
		step_away(T,usr,15)
		T.TakeDamage("head", 70, 0)
		T.updatehealth()
		for(var/i = 0, i < 5, i++)
			usr.pixel_y += 10
			sleep(1)
		usr.set_loc(T.loc)
		usr.weakened = 10
		usr.transforming = 0
		for(var/i = 0, i < 5, i++)
			usr.pixel_y -= 8
			sleep(1)
		usr.pixel_y = 0
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] elbow drops [] into oblivion!</B></span>", usr, T), 1)
		T.gib()

/mob/proc/batspin(mob/T as mob in oview(1))
	set category = "Batman"
	set name = "Bat Spin \[Finisher]"
	set desc = "Grab someone and spin them around until they explode"

	SPAWN_DBG(0)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] grabs [] tightly!</B></span>", usr, T), 1)
		usr.transforming = 1
		T.transforming = 1
		T.u_equip(l_hand)
		T.u_equip(r_hand)
		sleep(30)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] starts spinning [] around!</B></span>", usr, T), 1)
		for(var/i = 0, i < 2, i++)
			T.dir = NORTH
			sleep(5)
			T.dir = EAST
			sleep(5)
			T.dir = SOUTH
			sleep(5)
			T.dir = WEST
			sleep(5)
		for(var/i = 0, i < 1, i++)
			T.dir = NORTH
			sleep(2)
			T.dir = EAST
			sleep(2)
			T.dir = SOUTH
			sleep(2)
			T.dir = WEST
			sleep(2)
		boutput(T, "<span style=\"color:red\">YOU'RE GOING TOO FAST!!!</span>")
		for(var/i = 0, i < 10, i++)
			T.dir = NORTH
			sleep(1)
			T.dir = EAST
			sleep(1)
			T.dir = SOUTH
			sleep(1)
			T.dir = WEST
			sleep(1)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] suddenly explodes</B>!</span>", T), 1)
		T.gib()

/mob/proc/batdropkick(mob/T as mob in oview())
	set category = "Batman"
	set name = "Drop Kick \[Disabler]"
	set desc = "Fall to the ground, leap up and knock a dude out"

	SPAWN_DBG(0)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] falls to the ground</B>!</span>", usr), 1)
		usr.weakened += 760 // lol whatever
		sleep(20)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span style=\"color:red\"><B>[] launches towards []</B>!</span>", usr, T), 1)
		for(var/i=0, i<100, i++)
			step_to(usr,T,0)
			if (get_dist(usr,T) <= 1)
				T.weakened += 10
				T.stunned += 10
				for(var/mob/O in viewers(src, null))
					O.show_message(text("<span style=\"color:red\"><B>[] flies at [], slamming \him in the head</B>!</span>", usr, T), 1)
				usr.delStatus("weakened")
				i=100
			sleep(1)

