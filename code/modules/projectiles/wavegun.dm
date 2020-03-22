/datum/projectile/wavegun
	name = "energy wave"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "wave"
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 10
//How much ammo this costs
	cost = 33
//How fast the power goes away
	dissipation_rate = -3.3 //gets strong fast
//Range/time limiter on non-standard dissipation
	max_range = 36 //3x taser range
//How many tiles till it starts to lose power (gain, in this case)
	dissipation_delay = 3.3
//Kill/Stun ratio
	ks_ratio = 0.0
//name of the projectile setting, used when you change a guns setting
	sname = "inversion wave"
//file location for the sound you want it to play
	shot_sound = 'sound/weapons/rocket.ogg'
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type
/*
kinetic - raw power
piercing - punches though things
slashing - cuts things
energy - energy
burning - hot
radioactive - rips apart cells or some shit
toxic - poisons
*/
	damage_type = D_ENERGY
	//With what % do we hit mobs laying down
	hit_ground_chance = 33
	//Can we pass windows
	window_pass = 0


/datum/projectile/wavegun/transverse //expensive taser shots that go through /everything/
	shot_number = 1
	power = 10 //half the power of a taser at range 1-3, delivers a nasty punch at the 4-tile sweetspot
	dissipation_delay = 4
	dissipation_rate = -30
	max_range = 5 //super short. about 4 tile max range
	cost = 50
	hit_ground_chance = 100 //no escape
	pierces = -1 //no limits
	goes_through_walls = 1
	window_pass = 1
	damage_type = D_ENERGY
	sname = "transverse wave"
	icon_state = "wave-g"
		


		

/datum/projectile/wavegun/emp //emp and shit sparks. Maybe give this to pulse rifle?
	shot_number = 1
	power = 25
	dissipation_delay = 2
	dissipation_rate = -37.5 //only reliable past a few tiles
	max_range = 18 //taser-and-a-half range
	cost = 100 //two shots, unless you upgrade to a pulserifle/etc cell
	hit_ground_chance = 0
	sname = "electromagnetic distruption wave"
	icon_state = "wave-emp"

	on_hit(atom/H, angle, var/obj/projectile/P)
		var/turf/T = get_turf(H)
		if(prob(P.power))
			for(var/atom/O in T.contents)
				O.emp_act()
		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(5, 0, T)
		s.start()
	
	on_pointblank(obj/projectile/P, mob/living/M)
		if(prob(50))//make pointblanking less suck, but also only affect the target directly
			M.emp_act()
		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(5, 0, M)
		s.start()