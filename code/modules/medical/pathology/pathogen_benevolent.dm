datum/pathogeneffects/benevolent
	name = "Benevolent"
	rarity = RARITY_ABSTRACT

datum/pathogeneffects/benevolent/mending
	name = "Wound Mending"
	desc = "Slow paced brute damage healing."
	rarity = RARITY_UNCOMMON

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
		return null

datum/pathogeneffects/benevolent/cleansing
	name = "Cleansing"
	desc = "The pathogen cleans the body of damage caused by toxins."
	rarity = RARITY_RARE

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