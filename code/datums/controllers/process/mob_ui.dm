
datum/controller/process/mob_ui
	setup()
		name = "Mob UI"
		schedule_interval = 1 SECOND

	doWork()
		for(var/mob/M in mobs)
			M.handle_stamina_updates()
			scheck()
