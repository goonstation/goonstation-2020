datum/pathogeneffects/benevolent
	name = "Benevolent"
	rarity = RARITY_ABSTRACT
	beneficial = 1

datum/pathogeneffects/benevolent/mending
	name = "Wound Mending"
	desc = "Slow paced brute damage healing."
	rarity = RARITY_UNCOMMON
	danger_score = -6

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 5))
			M.HealDamage("chest", origin.stage < 3 ? 1 : 2, 0)
		M.updatehealth()

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "Microscopic damage on the synthetic flesh appears to be mended by the pathogen."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

datum/pathogeneffects/benevolent/healing
	name = "Burn Healing"
	desc = "Slow paced burn damage healing."
	rarity = RARITY_UNCOMMON
	danger_score = -6

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 5))
			M.HealDamage("chest", 0, origin.stage < 3 ? 1 : 2)
		M.updatehealth()

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "The pathogen does not appear to mend the synthetic flesh. Perhaps something that might cause other types of injuries might help."
		if (R == "infernite")
			if (zoom)
				return "The pathogen repels the scalding hot chemical and quickly repairs any damage caused by it to organic tissue."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

datum/pathogeneffects/benevolent/detoxication
	name = "Detoxication"
	desc = "The pathogen aids the host body in metabolizing ethanol."
	rarity = RARITY_COMMON
	danger_score = -2

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/times = 1
		if (origin.stage > 3)
			times++
		if (origin.stage > 4)
			times++
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			if (rid == "ethanol" || istype(R, /datum/reagent/fooddrink/alcoholic))
				met = 1
				for (var/i = 1, i <= times, i++)
					if (R) //Wire: Fix for Cannot execute null.on mob life().
						R.on_mob_life()
					if (!R || R.disposed)
						break
				if (R && !R.disposed)
					M.reagents.remove_reagent(rid, R.depletion_rate * times)
		if (met)
			M.reagents.update_total()

	react_to(var/R, var/zoom)
		if (R == "ethanol")
			return "The pathogen appears to have entirely metabolized the ethanol."

	may_react_to()
		return "The pathogen appears to react with a pure intoxicant."

datum/pathogeneffects/benevolent/metabolisis
	name = "Accelerated Metabolisis"
	desc = "The pathogen accelerates the metabolisis of all chemicals present in the host body."
	rarity = RARITY_RARE
	danger_score = 0

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/times = 1
		if (origin.stage > 3)
			times++
		if (origin.stage > 4)
			times++
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			met = 1
			for (var/i = 1, i <= times, i++)
				if (R) //Wire: Fix for Cannot execute null.on mob life().
					R.on_mob_life()
				if (!R || R.disposed)
					break
			if (R && !R.disposed)
				M.reagents.remove_reagent(rid, R.depletion_rate * times)
		if (met)
			M.reagents.update_total()


	react_to(var/R, var/zoom)
		return "The pathogen appears to have entirely metabolized... all chemical agents in the dish."

	may_react_to()
		return null

datum/pathogeneffects/benevolent/cleansing
	name = "Cleansing"
	desc = "The pathogen cleans the body of damage caused by toxins."
	rarity = RARITY_RARE
	danger_score = -6

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 5) && M.get_toxin_damage())
			M.take_toxin_damage(-1)
			if (origin.stage > 3)
				M.take_toxin_damage(-1)
				if (origin.stage > 4)
					M.take_toxin_damage(-1)
			M.updatehealth()
			if (prob(10))
				M.show_message("<span style=\"color:blue\">You feel cleansed.</span>")

	react_to(var/R, var/zoom)
		return "The pathogen appears to have entirely metabolized... all chemical agents in the dish."

	may_react_to()
		return null

datum/pathogeneffects/benevolent/oxygenconversion
	name = "Oxygen Conversion"
	desc = "The pathogen converts organic tissue into oxygen."
	rarity = RARITY_VERY_RARE
	danger_score = 0

	may_react_to()
		return "The pathogen appears to radiate a bubble of oxygen."

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			return "The pathogen consumes the synthflesh and converts it into oxygen."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (M:losebreath > 0)
			M.TakeDamage("chest", M:losebreath * 2, 0)
			M:losebreath = 0
			if (prob(25))
				M.show_message("<span style=\"color:red\">You feel your body deteriorating as you breathe on.</span>")
		if (M.get_oxygen_deprivation())
			if (origin.stage != 0)
				M.take_oxygen_deprivation(0 - (origin.stage / 2))
			M.updatehealth()

datum/pathogeneffects/benevolent/oxygenproduction
	name = "Oxygen Production"
	desc = "The pathogen produces oxygen."
	rarity = RARITY_VERY_RARE
	danger_score = -6

	may_react_to()
		return "The pathogen appears to radiate a bubble of oxygen."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (M:losebreath > 0)
			M:losebreath = 0
		if (M.get_oxygen_deprivation())
			M.take_oxygen_deprivation(0 - origin.stage)
			M.updatehealth()

datum/pathogeneffects/benevolent/resurrection
	name = "Necrotic Resurrection"
	desc = "The pathogen will resurrect you if it procs while you are dead."
	rarity = RARITY_VERY_RARE
	danger_score = -15

	may_react_to()
		return "Some of the pathogen's dead cells seem to remain active."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (origin.stage < 3)
			return
		if(prob(10 + origin.stage))
			M.emote("moan")
		if(prob(2 + origin.stage))
			M.show_message("<span style=\"color:red\">You feel a sudden craving for ... brains??</span>")

	disease_act_dead(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (origin.stage < 3)
			return
		// Shamelessly stolen from Strange Reagent
		if (isdead(M) || istype(get_area(M),/area/afterlife/bar))
			var/cap = 75 - origin.stage*6
			var/brute = (M.get_brute_damage()>cap)?(cap):M.get_brute_damage()
			var/burn = (M.get_burn_damage()>cap)?(cap):M.get_burn_damage()

			// let's heal them before we put some of the damage back
			// but they don't get back organs/limbs/whatever, so I don't use full_heal
			M.HealDamage("All", 100000, 100000)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M	
				H.blood_volume = 500 					// let's not have people immediately suffocate from being exsanguinated
				H.take_toxin_damage(-INFINITY)
				H.take_oxygen_deprivation(-INFINITY)

			M.TakeDamage("chest", brute, burn)			// this makes it so our burn and brute are between 0-45, so at worst we will have 10% hp
			M.take_brain_damage(cap)				// and a lot of brain damage
			setalive(M)
			M.changeStatus("paralysis", 150) 			// paralyze the person for a while, because coming back to life is hard work
			M.change_misstep_chance(40)					// even after getting up they still have some grogginess for a while
			M.stuttering = 15
			M.updatehealth()
			if (M.ghost && M.ghost.mind && !(M.mind && M.mind.dnr)) // if they have dnr set don't bother shoving them back in their body
				M.ghost.show_text("<span style=\"color:red\"><B>You feel yourself being dragged out of the afterlife!</B></span>")
				M.ghost.mind.transfer_to(M)
				qdel(M.ghost)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.contract_disease(/datum/ailment/disease/tissue_necrosis, null, null, 1) // this disease will make the person more and more rotten even while alive
				H.remission(origin)			// set the pathogen into remission, so it will be gone soon. Unlikely for a person to revive twice like this!
				H.immunity(origin)
				H.visible_message("<span style=\"color:red\">[H] suddenly starts moving again!</span>","<span style=\"color:red\">You feel the pathogen weakening as you rise from the dead.</span>")

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
			return "Dead parts of the synthflesh seem to still be transferring blood."
		else return null


datum/pathogeneffects/benevolent/brewery
	name = "Auto-Brewery"
	desc = "The pathogen aids the host body in metabolizing chemicals into ethanol."
	rarity = RARITY_RARE
	beneficial = 0 // fuck this liver disease isn't beneficial
	danger_score = 6

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/times = 1
		if (origin.stage > 3)
			times++
		if (origin.stage > 4)
			times++
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			if (!(rid == "ethanol" || istype(R, /datum/reagent/fooddrink/alcoholic)))
				met = 1
				for (var/i = 1, i <= times, i++)
					if (R) //Wire: Fix for Cannot execute null.on mob life().
						R.on_mob_life()
					if (!R || R.disposed)
						break
				if (R && !R.disposed)
					var/amt = R.depletion_rate * times
					M.reagents.remove_reagent(rid, amt)
					M.reagents.add_reagent("ethanol", amt)
		if (met)
			M.reagents.update_total()

	react_to(var/R, var/zoom)
		if (!(R == "ethanol"))
			return "The pathogen appears to have entirely metabolized all chemical agents in the dish into... ethanol."

	may_react_to()
		return "The pathogen appears to react with anything but a pure intoxicant."


datum/pathogeneffects/benevolent/bioluminescence
	name = "Bioluminescence"
	desc = "The pathogen makes the afflicted emit light and sometimes flash the area when attacked."
	rarity = RARITY_RARE
	danger_score = -8

	var/rgb = null
	
	proc/getColor(var/datum/pathogen/origin)
		if(origin.suppressant != null)
			switch(origin.suppressant.color)
				if("blue")
					return list(0, 0, 255)
				if("red")
					return list(255, 0, 0)
				if("green")
					return list(0, 255, 2505)
				if("black") // fuck
					return list(100, 100, 100)
				if("cyan")
					return list(0, 255, 255)
				if("white")
					return list(255, 255, 255)
				if("orange")
					return list(255, 165, 0)
				if("pink")
					return list(255, 192, 203)
				if("viridian")
					return list(64, 130, 109)
				if("olive drab")
					return list(107, 142, 35)
				else
					return list(255, 215, 0) // probably admin created, so let's make it golden! Also, how is there even no yellow suppressant?

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if(rgb == null)
			rgb = getColor(origin)
		var/brightness = 255 * origin.stage * 0.2
		M.add_simple_light("bioluminescence", rgb + brightness)

	oncured(mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		message_admins("We are cured! It's a miracle!")
		M.remove_simple_light("bioluminescence")

	onpunched(var/mob/M as mob, var/mob/A as mob, zone, var/datum/pathogen/origin)
		if(origin.stage < 3) // stages 3 and over
			return 1
		if(prob(origin.stage*6))
			M.visible_message("<span style=\"color:red\">[M] emits a bright flash of light!</span>", "<span style=\"color:blue\">You flinch and emit a large amount of light.</span>", "<span style=\"color:red\">You can feel warmth on your skin.</span>")
			if(origin.stage >= 5 && prob(25))
				A.show_message("<span style=\"color:red\">YOUR EYES!</span>")
				A.apply_flash(60, weak = 0, eye_tempblind = 10)
			var/strength = origin.stage-2
			var/obj/itemspecialeffect/glare/E = unpool(/obj/itemspecialeffect/glare)
			E.color = "#FFFFFF"
			E.setup(M.loc)
			playsound(M, "sound/weapons/singsuck.ogg", 25, 1)
			for (var/mob/living/B in oviewers(5, M))
				if (issilicon(B) || isintangible(B))
					continue
				var/dist = get_dist(B, M)
				var/weakened = max(0, 0.5 * strength * (3 - dist))
				var/eye_damage = max(0, 0.5 * strength * (2 - dist))
				var/eye_blurry = max(0, 1 * strength * (5 - dist))
				B.apply_flash(60, max(0, weakened), 0, 10, max(0, eye_blurry), max(0, eye_damage))
		return 1

	may_react_to()
		return "The pathogen seems to be faintly glowing."

