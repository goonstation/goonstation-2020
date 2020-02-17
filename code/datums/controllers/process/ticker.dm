// handles the game ticker
datum/controller/process/ticker
	setup()
		name = "Game"
		schedule_interval = 5

		if(!ticker)
			ticker = new /datum/controller/gameticker()

		// start the pregame process
		SPAWN_DBG(1)
			ticker.pregame()
	doWork()
		ticker.process()