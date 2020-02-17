//Nanomachines!

/datum/ailment/disease/robotic_transformation
	name = "Robotic Transformation"
	scantype = "Nano-Infection"
	max_stages = 5
	spread = "Non-Contagious"
	cure = "Electric Shock"
	associated_reagent = "nanites"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/robotic_transformation/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if (prob(8))
				boutput(affected_mob, "Your joints feel stiff.")
				random_brute_damage(affected_mob, 1)
			if (prob(9))
				boutput(affected_mob, "<span style=\"color:red\">Beep...boop..</span>")
			if (prob(9))
				boutput(affected_mob, "<span style=\"color:red\">Bop...beeep...</span>")
		if(3)
			if (prob(8))
				boutput(affected_mob, "<span style=\"color:red\">Your joints feel very stiff.</span>")
				random_brute_damage(affected_mob, 5)
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"))
			if (prob(10))
				boutput(affected_mob, "Your skin feels loose.")
				random_brute_damage(affected_mob, 5)
			if (prob(4))
				boutput(affected_mob, "<span style=\"color:red\">You feel a stabbing pain in your head.</span>")
				affected_mob.changeStatus("paralysis", 40)
			if (prob(4))
				boutput(affected_mob, "<span style=\"color:red\">You can feel something move...inside.</span>")
		if(4)
			if (prob(10))
				boutput(affected_mob, "<span style=\"color:red\">Your skin feels very loose.</span>")
				random_brute_damage(affected_mob, 8)
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))
			if (prob(8))
				boutput(affected_mob, "<span style=\"color:red\">You can feel... something...inside you.</span>")
		if(5)
			boutput(affected_mob, "<span style=\"color:red\">Your skin feels as if it's about to burst off...</span>")
			affected_mob.take_toxin_damage(10)
			affected_mob.updatehealth()
			if(prob(40)) //So everyone can feel like robot Seth Brundle

				var/bdna = null // For forensics (Convair880).
				var/btype = null
				if (affected_mob.bioHolder.Uid && affected_mob.bioHolder.bloodType)
					bdna = affected_mob.bioHolder.Uid
					btype = affected_mob.bioHolder.bloodType

				var/turf/T = find_loc(affected_mob)
				gibs(T, null, null, bdna, btype)

				if (ismonkey(affected_mob) || jobban_isbanned(affected_mob, "Cyborg"))
					affected_mob.ghostize()
					var/robopath = pick(/obj/machinery/bot/guardbot,/obj/machinery/bot/secbot,/obj/machinery/bot/medbot,/obj/machinery/bot/firebot,/obj/machinery/bot/cleanbot,/obj/machinery/bot/floorbot)
					new robopath (T)
					qdel(affected_mob)
				else if (ishuman(affected_mob))
					affected_mob:Robotize_MK2(1)
