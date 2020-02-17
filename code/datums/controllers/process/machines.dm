// handles machines
datum/controller/process/machines
	var/tmp/list/machines
	var/tmp/list/pipe_networks
	var/tmp/list/powernets
	var/tmp/list/atmos_machines

	setup()
		name = "Machine"
		schedule_interval = 33

		Station_VNet = new /datum/v_space/v_space_network()

	proc/d_print()
		for(var/obj/machinery/machine in src.machines)
			boutput(world,"[machine.name] : [machine.type]")

	doWork()
		src.atmos_machines = global.atmos_machines
		var/c = 0
		for(var/obj/machinery/machine in atmos_machines)
			if( machine.z == 4 && !Z4_ACTIVE ) continue
#ifdef MACHINE_PROCESSING_DEBUG
			var/t = world.time
#endif
			machine.process()
#ifdef MACHINE_PROCESSING_DEBUG
			register_machine_time(machine, world.time - t)
#endif

			if (!(c++ % 100))
				scheck()

		src.pipe_networks = global.pipe_networks
		for(var/datum/pipe_network/network in src.pipe_networks)
#ifdef MACHINE_PROCESSING_DEBUG
			var/t = world.time
#endif
			network.process()
#ifdef MACHINE_PROCESSING_DEBUG
			register_machine_time(network, world.time - t)
#endif
			if (!(c++ % 100))
				scheck()

		src.powernets = global.powernets
		for(var/datum/powernet/PN in src.powernets)
#ifdef MACHINE_PROCESSING_DEBUG
			var/t = world.time
#endif
			PN.reset()
#ifdef MACHINE_PROCESSING_DEBUG
			register_machine_time(PN, world.time - t)
#endif
			if (!(c++ % 100))
				scheck()

		src.machines = global.machines
		for(var/obj/machinery/machine in src.machines)
			if( machine.z == 4 && !Z4_ACTIVE ) continue
#ifdef MACHINE_PROCESSING_DEBUG
			var/t = world.time
#endif
			machine.process()
#ifdef MACHINE_PROCESSING_DEBUG
			register_machine_time(machine, world.time - t)
#endif
			if (!(c++ % 100))
				scheck()


#ifdef MACHINE_PROCESSING_DEBUG
proc/register_machine_time(var/datum/machine, var/time)
	if(!machine) return
	var/list/mtl = detailed_machine_timings[machine.type]
	if(!mtl)
		mtl = list()
		mtl.len = 2
		mtl[1] = 0	//The amount of time spent processing this machine in total
		mtl[2] = 0	//The amount of times this machine has been processed
		detailed_machine_timings[machine.type] = mtl

	mtl[1] += time
	mtl[2]++


#endif