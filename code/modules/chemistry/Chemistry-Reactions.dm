/proc/ldmatter_reaction(var/datum/reagents/holder, var/created_volume, var/id)
	var/cube = 0
	var/atom/psource = holder.my_atom
	while (psource)
		psource = psource.loc
		if (istype(psource, /obj) && !isitem(psource) && (istype(psource, /obj/machinery/vehicle) || !istype(psource, /obj/machinery)) && !istype(psource, /obj/submachine))
			cube = 1
			break

	var/list/covered = holder.covered_turf()
	if (!covered || !covered.len)
		covered = list(get_turf(holder.my_atom))

	var/howmany = max(1,covered.len / 2.2)
	for(var/i = 0, i < howmany, i++)
		var/atom/source = pick(covered)
		new/obj/decal/implo(source)
		playsound(source, 'sound/effects/suck.ogg', 100, 1)

		if (cube)
			for (var/mob/living/carbon/human/H in psource)
				H.set_loc(source)
				logTheThing("combat", H, null, "becomes a meatcube due to ldmatter implosion.")
				H.make_cube(/mob/living/carbon/cube/meat, INFINITY)
			for (var/mob/living/silicon/S in psource) //Now that we have silicon cubes, why not.
				S.set_loc(source)
				logTheThing("combat", S, null, "becomes a metalcube due to ldmatter implosion.")
				S.make_cube(/mob/living/carbon/cube/metal, INFINITY)
			for (var/obj/O in psource)
				O.set_loc(source)
			psource:visible_message("<span style=\"color:red\">[psource] implodes!</span>")
			qdel(psource)
			return

		for(var/atom/movable/M in view(3 + (created_volume > 30 ? 1:0), source))
			if(M.anchored || M == source || M.throwing) continue
			M.throw_at(source, 20 + round(created_volume * 2), 1 + round(created_volume / 10))
			LAGCHECK(LAG_MED)
	if (holder)
		holder.del_reagent(id)

/proc/smoke_reaction(var/datum/reagents/holder, var/smoke_size, var/turf/location, var/vox_smoke = 0, var/do_sfx = 1)
	var/block = 0
	if (holder.my_atom)
		var/atom/psource = holder.my_atom.loc
		while (psource)
			if (istype(psource, /obj/machinery/vehicle))
				block = 1
				break
			psource = psource.loc

	if (block)
		return 0

	var/og_smoke_size = smoke_size

	var/list/covered = holder.covered_turf()
	if (!covered || !covered.len)
		covered = list(get_turf(holder.my_atom))

	var/howmany = max(1,covered.len / 4)
	for(var/i = 0, i < howmany, i++)
		var/turf/source = 0
		if (location)
			source = location
		else
			source = pick(covered)

		if (!source)
			continue

		if (do_sfx)
			if (narrator_mode || vox_smoke)
				playsound(location, 'sound/vox/smoke.ogg', 50, 1, -3)
			else
				playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)

		//particleMaster.SpawnSystem(new /datum/particleSystem/chemSmoke(source, holder, 20, smoke_size))

		var/prev_group_exists = 0
		var/diminishing_returns_thingymabob = 1000//MBC MAGIC NUMBERS :)

		var/react_amount = holder.total_volume
		if (source.active_airborne_liquid && source.active_airborne_liquid.group)
			prev_group_exists = 1
			var/datum/fluid_group/FG = source.active_airborne_liquid.group

			if (FG.contained_amt > diminishing_returns_thingymabob)
				react_amount = react_amount / (1 + ((FG.contained_amt - diminishing_returns_thingymabob) * 0.1))//MBC MAGIC NUMBERS :)
				//boutput(world,"[react_amount]")

		var/divisor = covered.len
		if (covered.len > 4)
			divisor += 0.2
		source.fluid_react(holder, react_amount/divisor, airborne = 1)

		if (!prev_group_exists && source.active_airborne_liquid && source.active_airborne_liquid.group)
			var/datum/fluid_group/FG = source.active_airborne_liquid.group
			while (smoke_size >= 0)
				FG.update_once(og_smoke_size * og_smoke_size)
				smoke_size--

	holder.clear_reagents()



/proc/classic_smoke_reaction(var/datum/reagents/holder, var/smoke_size, var/turf/location, var/vox_smoke = 0)
	var/block = 0
	if (holder.my_atom)
		var/atom/psource = holder.my_atom.loc
		while (psource)
			if (istype(psource, /obj/machinery/vehicle))
				block = 1
				break
			psource = psource.loc

	if (block)
		return 0

	if (narrator_mode || vox_smoke)
		playsound(location, 'sound/vox/smoke.ogg', 50, 1, -3)
	else
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)

	var/list/covered = holder.covered_turf()
	if (!covered || !covered.len)
		covered = list(get_turf(holder.my_atom))

	var/howmany = max(1,covered.len / 5)

	var/turf/source = 0

	for(var/i = 0, i < howmany, i++)
		if (location)
			source = location
		else
			source = pick(covered)
		particleMaster.SpawnSystem(new /datum/particleSystem/chemSmoke(source, holder, 20, smoke_size / howmany))
