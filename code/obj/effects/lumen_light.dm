/obj/effects/lumen_light
	name = ""
	desc = ""
	density = 0
	anchored = 1
	mouse_opacity = 0
	var/datum/light/light
	var/create_time = 0 //for process loop
	var/life_length = 0 //assigned a random value

	New()
		light = new /datum/light/point
		light.attach(src)
		create_time = world.time
		life_length = rand(3000, 6000) //random time from 5 to 10 minutes
		processing_items += src

	proc/process()
		if (world.time >= create_time + life_length)
			qdel(src)
