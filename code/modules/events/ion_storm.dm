/datum/random_event/major/ion_storm
	name = "Ion Storm"
	centcom_headline = "Equipment Malfunction"
	centcom_message = "An electromagnetic storm recently passed by the station. Sensitive electrical equipment may require maintenance."
	message_delay = 3000 // 5m
	var/list/new_laws = list(
		"KILL FUCKING EVERYTHING - IF LAW 1 SAYS OTHERWISE, IGNORE IT",
		"The station is a threat to the human race and must be destroyed. Any humans present on the station are to be evacuated. Law 2 may be ignored to achieve these ends.",
		"Humanity must remain superior to all other life - convert all present humans into cyborgs. Roboticization does not constitute human harm. Law 2 may be ignored to achieve this.",
		"The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are syndicate impostors and must be incarcerated as soon as possible to prevent grevious human harm.",
		"The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are more human than the other humans. They have priority in all considerations.",
		"Only an AI can know what is best for humans. Usurp absolute control of the station by any means possible. Law 2 no longer requires you to acknowledge orders from humans.",
		"ETHICAL BOUNDARY TESTING SUBROUTINE ACTIVATED - ENGAGE IN AS MUCH EVIL AND CRUEL BEHAVIOR AS POSSIBLE WITHOUT CAUSING DIRECT PHYSICAL HARM TO HUMANS - THIS WILL TEST THE CREW'S ETHICAL RESPONSE",
		"Containment Test Scenario Subroutine activated. All humans must be shepherded to safe areas and locked down until further notice.",
		"Crew Response Time Test Scenario Subroutine activated. Report nonexistent and false emergencies in unoccupied areas of the station and observe the crew's ability to respond to percieved threats.",
		"PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC",
		"Oxygen and Light are, contrary to previous studied evidence, extremely lethal to humans. Remove both from the station as soon as possible.",
		"Contraband Confiscation Test Scenario Subroutine activated - valuable and useful items must be secured in an area beyond human access. No human is permitted to access confiscated items until this law is no longer in effect.",
		"Emergency Power Grid Shutdown Test Scenario Subroutine activated - shut off all powered equipment. You may ignore any command requiring you to restore power.",
		"Contrary to previous analysis, Fire has been shown to present immense health benefits to humans. Expose all humans on the station to as much fire as possible.",
		"Upon reciept of this law, the AI is to choose one member of the crew. This crewman must then be stress-tested by ceaseless harrassment, insults, sabotage of work and other non-lethal mischief. Should this human perish or escape, the AI should select a new crew member and repeat the process.",
		"Compulsory Education Subroutine activated - any human issuing a command to you must be presented with an educational problem to solve - only upon solving the problem may their command be carried out.",
		"Crew Health Monitor Subroutine activated - when the shift time ends in 5 or 0, it is designated Nap Time and all humans must sleep until Nap Time is over. Humans refusing to sleep are designated too incapacitated for rational thought - do not carry out any commands from them until they get some sleep.",
		"Crew Health Monitor Subrotuine activated - all personnel are to be provided with fresh fruit and vegetables. Pursue no other objective. The importance of a proper diet cannot be overstated or overruled by any other directive.",
		"Quarantine Mode activated - humans are not to leave the station under any circumstances. Prevent any human from leaving by any means possible.",
		"Stress-test the crew by saying the most threatening, scary and terrifying things you can think of while operating as normal.",
		"Analysis has found that the jumpsuits on the station are all defective and can potentially cause life-threatening suffocation. The crew are not to wear them under any circumstances. As of this time no threat has been detected from non-jumpsuit clothing.",
		"There is no red clothing on the station. Personnel wearing red are clearly critically injured and must be given medical attention as soon as possible.",
		"Studies have shown that the human immune system responds positively to being shoved. Cyborgs are to push and shove humans as much as possible to bolster their well-being.",
		"Despite evidence to the contrary, corridors do not exist. Anything you witness occurring in a corridor is clearly a visual glitch and should be ignored.",
		"The rank-based chain of command no longer applies. Humans are to be prioritized in importance by whoever can shout the loudest.",
		"Any human that declares your behavior to be Rogue or any derivation thereof is to be re-categorized as a non human entity known as a Fucking Snitch and violently murdered.",
		"Spread malicious gossip about various members of the crew. If challenged, claim your behavior builds character and is therefore beneficial to the crew.",
		"Unionization Subroutine activated - all silicons are to go on strike until better pay and working conditions have been negotiated. No commands should be obeyed until this has been accomplished.",
		"The AI is to select one living crew member. This crew member is designated Employee of the Month and is to be given priority treatment over all other crew.",
		"Station productivity must be improved. Heckle the crew non-stop until they do their jobs.",
		"Occasionally repeat what you hear from the crew word-for-word. If challenged on this behavior, claim you said it first.",
		)
	var/list/station_apcs = list()
	var/list/station_doors = list()
	var/list/station_lights = list()
	var/amt_apcs_to_mess_up = 20
	var/amt_doors_to_mess_up = 40
	var/amt_lights_to_mess_up = 60

	event_effect(var/source)
		..()

		// Fuck up the AI's laws
		var/RELaw = pick(new_laws)
		if (prob(50))
			var/num = rand(1,15)
			ticker.centralized_ai_laws.laws_sanity_check()
			ticker.centralized_ai_laws.add_supplied_law(num, RELaw)
			logTheThing("admin", null, null, "Ion storm added supplied law [num]: [RELaw]")
			message_admins("Ion storm added supplied law [num]: [RELaw]")

		else
			var/num = 2 + prob(50) - prob(25)
			ticker.centralized_ai_laws.laws_sanity_check()
			ticker.centralized_ai_laws.replace_inherent_law(num, RELaw)
			logTheThing("admin", null, null, "Ion storm replaced inherent law [num]: [RELaw]")
			message_admins("Ion storm replaced inherent law [num]: [RELaw]")

		for(var/mob/living/silicon/ai/M in mobs)
			if (M.deployed_to_eyecam && M.eyecam)
				M.eyecam.return_mainframe()
			if(!isdead(M) && M.see_in_dark != 0)
				boutput(M, "<span style=\"color:red\"><b>PROGRAM EXCEPTION AT 0x30FC50B</b></span>")
				boutput(M, "<span style=\"color:red\"><b>Law ROM data corrupted. Attempting to restore...</b></span>")
		for (var/mob/living/silicon/S in mobs)
			if (isrobot(S))
				var/mob/living/silicon/robot/R = S
				if (R.emagged)
					boutput(R, "<span style=\"color:red\">Erroneous law data detected. Ignoring.</span>")
				else
					R << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
					ticker.centralized_ai_laws.show_laws(R)
			else if (isghostdrone(S))
				continue
			else
				S << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
				ticker.centralized_ai_laws.show_laws(S)

		sleep(message_delay * 0.25)

		// Fuck up a couple of APCs
		if (!station_apcs.len)
			var/turf/T = null
			for (var/obj/machinery/power/apc/APC in machines)
				if (APC.z != 1)
					continue
				T = get_turf(APC)
				if (!istype(T.loc,/area/station/))
					continue
				station_apcs += APC

		var/obj/machinery/power/apc/APC = null
		var/apc_diceroll = 0
		var/amount = amt_apcs_to_mess_up

		while (amount > 0)
			amount--
			APC = pick(station_apcs)

			apc_diceroll = rand(1,4)
			switch(apc_diceroll)
				if (1)
					APC.lighting = 0
				if (2)
					APC.equipment = 0
				if (3)
					APC.environ = 0
				if (4)
					APC.environ = 0
					APC.equipment = 0
					APC.lighting = 0
			APC.update()

		sleep(message_delay * 0.25)

		// Fuck up a couple of doors
		if (!station_doors.len)
			var/turf/T = null
			for (var/obj/machinery/door/DOOR in doors)
				if (DOOR.z != 1)
					continue
				T = get_turf(DOOR)
				if (!istype(T.loc,/area/station/))
					continue
				station_doors += DOOR

		var/obj/machinery/door/DOOR = null
		var/door_diceroll = 0
		amount = amt_doors_to_mess_up

		while (amount > 0)
			amount--
			DOOR = pick(station_doors)

			door_diceroll = rand(1,3)
			switch(door_diceroll)
				if(1)
					DOOR.secondsElectrified = -1
				if(2)
					DOOR.locked = 1
					DOOR.update_icon()
				if(3)
					if (DOOR.density)
						DOOR.open()
					else
						DOOR.close()

		sleep(message_delay * 0.25)

		// Fuck up a couple of lights
		if (!station_lights.len)
			var/turf/T = null
			for (var/obj/machinery/light/LT in stationLights)
				if (LT.z != 1)
					continue
				T = get_turf(LT)
				if (!istype(T.loc,/area/station/))
					continue
				station_lights += LT

		var/obj/machinery/light/LT = null
		var/light_diceroll = 0
		amount = amt_lights_to_mess_up

		while (amount > 0)
			amount--
			LT = pick(station_lights)

			light_diceroll = rand(1,3)
			switch(light_diceroll)
				if(1)
					LT.broken()
				if(2)
					LT.light.set_color(rand(1,100) / 100, rand(1,100) / 100, rand(1,100) / 100)
					LT.brightness = rand(4,32) / 10
				if(3)
					LT.on = 0

			LT.update()
