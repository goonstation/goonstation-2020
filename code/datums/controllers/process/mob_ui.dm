
datum/controller/process/mob_ui
	setup()
		name = "Mob UI"
		schedule_interval = 1 SECONDS

	doWork()
		for(var/mob/M in mobs)
			M.handle_stamina_updates()
			scheck()
