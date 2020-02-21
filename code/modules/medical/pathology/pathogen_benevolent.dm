#define SPREAD_FACE 1
#define SPREAD_BODY 2
#define SPREAD_HANDS 4
#define SPREAD_AIR 8

datum/pathogeneffects/benevolent
	name = "Benevolent"
	rarity = RARITY_ABSTRACT

datum/pathogeneffects/benevolent/mending
	name = "Wound Mending"
	desc = "Slow paced brute damage healing."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		//if (prob(origin.stage * 5))
		M.HealDamage("All", origin.stage / 2, 0)
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
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		//if (prob(origin.stage * 5))
		M.HealDamage("All", 0, origin.stage / 2)
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

datum/pathogeneffects/benevolent/fleshrestructuring
	name = "Flesh Restructuring"
	desc = "Fast paced general healing."
	rarity = RARITY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 5))
			M.HealDamage("All", origin.stage, origin.stage)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.bleeding)
					repair_bleeding_damage(M, 80, 2)
			if (prob(50))
				M.show_message("<span style=\"color:blue\">You feel your wounds closing by themselves.</span>")
		M.updatehealth()

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "The pathogen appears to mimic the behavior of the synthetic flesh."
		if (R == "acid")
			if (zoom)
				return "The pathogen becomes agitated and works to repair the damage caused by the sulfuric acid."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue to an unprecedented degree."
	//podrickequus's first code, yay

datum/pathogeneffects/benevolent/detoxication
	name = "Detoxication"
	desc = "The pathogen aids the host body in metabolizing ethanol."
	rarity = RARITY_COMMON

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
		return "The pathogen appears to be rapidly breaking down certain materials around it."

datum/pathogeneffects/benevolent/cleansing
	name = "Cleansing"
	desc = "The pathogen cleans the body of damage caused by toxins."
	rarity = RARITY_UNCOMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		//if (prob(origin.stage * 5) && M.get_toxin_damage())
		if (M.get_toxin_damage())
			M.take_toxin_damage(-origin.stage / 2)
			M.updatehealth()
			if (prob(12))
				M.show_message("<span style=\"color:blue\">You feel cleansed.</span>")

	react_to(var/R, var/zoom)
		return "The pathogen appears to have entirely metabolized... all chemical agents in the dish."

	may_react_to()
		return "The pathogen seems to be much cleaner than normal."

datum/pathogeneffects/benevolent/oxygenconversion
	name = "Oxygen Conversion"
	desc = "The pathogen converts organic tissue into oxygen."
	rarity = RARITY_VERY_RARE

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

datum/pathogeneffects/benevolent/brewery
	name = "Auto-Brewery"
	desc = "The pathogen aids the host body in metabolizing chemicals into ethanol."
	rarity = RARITY_RARE

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

datum/pathogeneffects/benevolent/oxytocinproduction
	name = "Oxytocin Production"
	desc = "The pathogen produces Pure Love within the infected."
	infect_type = INFECT_TOUCH
	rarity = RARITY_COMMON
	permeability_score = 15
	spread = SPREAD_BODY | SPREAD_HANDS
	infection_coefficient = 1.5
	infect_message = "<span style=\"color:pink\">You can't help but feel loved.</span>"

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/check_amount = M.reagents.get_reagent_amount("love")
		if (!check_amount || check_amount < 5)
			M.reagents.add_reagent("love", origin.stage / 2)
		if (prob(origin.stage * 2.5))
			infect(M, origin)

	may_react_to()
		return "The pathogen's cells appear to be... hugging each other?"

datum/pathogeneffects/benevolent/neuralreconstruction
	name = "Neural Reconstruction"
	desc = "Infection slowly repairs damage done to the brain."
	rarity = RARITY_UNCOMMON
	infect_type = INFECT_NONE
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (2)
				if (prob(5))
					M.take_brain_damage(-1)
			if (3)
				if (prob(15))
					M.take_brain_damage(-1)
			if (4)
				if (prob(25))
					M.take_brain_damage(-2)
			if (5)
				if (prob(35))
					M.take_brain_damage(-2)

	react_to(var/R, var/zoom)
		if (!(R == "neurotoxin"))
			return "The pathogen seems to release a chemical in an attempt to counteract the effects of the neurotoxin."

	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."