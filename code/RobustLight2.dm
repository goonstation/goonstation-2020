var
	RL_Generation = 0

#define RL_Atten_Quadratic 2.2 // basically just brightness scaling atm
#define RL_Atten_Constant -0.11 // constant subtracted at every point to make sure it goes <0 after some distance
#define RL_MaxRadius 6 // maximum allowed light.radius value. if any light ends up needing more than this it'll cap and look screwy
#define DLL 0.05 //Darkness Lower Limit, at 0 things can get absolutely pitch black.

#define D_BRIGHT 1
#define D_COLOR 2
#define D_HEIGHT 4
#define D_ENABLE 8
#define D_MOVE 16
						//only if lag							OR we already have stuff queued   	also game needs to be started lol		and not doing a queue process currently
//#define SHOULD_QUEUE ((world.tick_usage > LIGHTING_MAX_TICKUSAGE || light_update_queue.cur_size) && current_state > GAME_STATE_SETTING_UP && !queued_run)
#define SHOULD_QUEUE (( light_update_queue.cur_size || world.tick_usage > LIGHTING_MAX_TICKUSAGE) && !queued_run && current_state > GAME_STATE_SETTING_UP)
datum/light
	var
		x
		y
		z

		x_des
		y_des
		z_des

		r = 1
		g = 1
		b = 1

		r_des = 1
		g_des = 1
		b_des = 1

		brightness = 1

		brightness_des = 1

		height = 1

		height_des = 1

		enabled = 0

		radius = 1
		premul_r = 1
		premul_g = 1
		premul_b = 1

		atom/attached_to = null
		attach_x = 0.5
		attach_y = 0.5

		dirty_flags = 0

		//queued_run = 0

	New(x=0, y=0, z=0)
		src.x = x
		src.y = y
		src.z = z
		var/turf/T = locate(x, y, z)
		if (T)
			if (!T.RL_Lights)
				T.RL_Lights = list()
			T.RL_Lights |= src


	disposing()
		disable(queued_run = 1) //dont queue... we wanna actually disable it before remove_from_turf etc
		remove_from_turf()
		detach()

	proc
		set_brightness(brightness, queued_run = 0)
			src.brightness_des = brightness
			if (src.brightness == brightness && !queued_run)
				return

			if (src.enabled)
				if (SHOULD_QUEUE)
					light_update_queue.queue(src)
					dirty_flags |= D_BRIGHT
					return

				var/strip_gen = ++RL_Generation
				var/list/affected = src.strip(strip_gen)

				src.brightness = brightness
				src.precalc()

				for (var/turf/T in src.apply())
					T.RL_UpdateLight()
				for (var/turf/T in affected)
					if (T.RL_UpdateGeneration <= strip_gen)
						T.RL_UpdateLight()
			else
				src.brightness = brightness
				src.precalc()

		set_color(red, green, blue, queued_run = 0)

			if (src.r == red && src.g == green && src.b == blue && !queued_run)
				return

			/*
			src.r_des = red
			src.g_des = green
			src.b_des = blue
			*/

			//hello yes now it's ZeWaka exporting my hellcode implementations across the code
			//scientific reasoning provided by Mokrzycki, Wojciech & Tatol, Maciej. (2011).
			/*
			var/R_sr = ((red + src.r*255) /2) //average value of R components in the two compared colors

			var/deltaR2 = abs(red   - (src.r*255))**2
			var/deltaG2 = abs(blue  - (src.b*255))**2
			var/deltaB2 = abs(green - (src.g*255))**2
			*/
			//this is our weighted euclidean distance function, weights based on red component
			//var/color_delta =( (2+(R_sr/256))*deltaR2 + (4*deltaG2) + (2+((255-R_sr)/256))*deltaB2 )

			//DEBUG_MESSAGE("[x],[y]:[temperature], d:[color_delta], [red]|[green]|[blue] vs [src.*255]|[src.*255]|[src.*255]")

			/*
			// This breaks everything if a light's value is 0, so, begone
			if (color_delta < 144) //determined via E'' sampling in science paper above, 144=12^2
				Z_LOG_DEBUG("Lighting", "Color update would be ignored due to color_delta ([color_delta]) under 144. ([R_sr], [deltaR2] [deltaG2] [deltaB2])")
				return
			*/

			if (src.enabled)
				if (SHOULD_QUEUE)
					light_update_queue.queue(src)
					dirty_flags |= D_COLOR
					return

				var/strip_gen = ++RL_Generation
				var/list/affected = src.strip(strip_gen)

				src.r = red
				src.g = green
				src.b = blue
				src.precalc()

				for (var/turf/T in src.apply())
					T.RL_UpdateLight()
				for (var/turf/T in affected)
					if (T.RL_UpdateGeneration <= strip_gen)
						T.RL_UpdateLight()
			else
				src.r = red
				src.g = green
				src.b = blue
				src.precalc()

		set_height(height, queued_run = 0)
			src.height_des = height
			if (src.height == height && !queued_run)
				return

			if (src.enabled)
				if (SHOULD_QUEUE)
					light_update_queue.queue(src)
					dirty_flags |= D_HEIGHT
					return

				var/strip_gen = ++RL_Generation
				var/list/affected = src.strip(strip_gen)

				src.height = height
				src.precalc()

				for (var/turf/T in src.apply())
					T.RL_UpdateLight()
				for (var/turf/T in affected)
					if (T.RL_UpdateGeneration <= strip_gen)
						T.RL_UpdateLight()
			else
				src.height = height
				src.precalc()

		enable(queued_run = 0)
			if (enabled)
				dirty_flags &= ~D_ENABLE
				return

			if (SHOULD_QUEUE)
				light_update_queue.queue(src)
				dirty_flags |= D_ENABLE
				return

			enabled = 1

			for (var/turf/T in src.apply())
				T.RL_UpdateLight()

		disable(queued_run = 0)
			if (!enabled)
				dirty_flags &= ~D_ENABLE
				return

			if (SHOULD_QUEUE)
				light_update_queue.queue(src)
				dirty_flags |= D_ENABLE
				return

			enabled = 0

			for (var/turf/T in src.strip(++RL_Generation))
				T.RL_UpdateLight()

		detach()
			if (src.attached_to)
				src.attached_to.RL_Attached -= src
				src.attached_to = null

		attach(atom/A, offset_x=0.5, offset_y=0.5)
			if (src.attached_to)
				var/atom/old = src.attached_to
				old.RL_Attached -= src

			if (!A.RL_Attached)
				A.RL_Attached = list(src)
			else
				A.RL_Attached += src

			src.move(A.x + offset_x, A.y + offset_x, A.z)
			src.attached_to = A
			src.attach_x = offset_x
			src.attach_y = offset_y


		// internals
		precalc()
			src.premul_r = src.r * src.brightness
			src.premul_g = src.g * src.brightness
			src.premul_b = src.b * src.brightness
			src.radius = min(round(sqrt(max((brightness * RL_Atten_Quadratic) / -RL_Atten_Constant - src.height**2, 0))), RL_MaxRadius)

		apply()
			if (!RL_Started || RL_Suspended)
				return list()

			return apply_internal(++RL_Generation, src.premul_r, src.premul_g, src.premul_b)

		strip(generation)
			if (!RL_Started || RL_Suspended)
				return list()

			return apply_internal(generation, -src.premul_r, -src.premul_g, -src.premul_b)

		remove_from_turf()
			var/turf/T = locate(src.x, src.y, src.z)
			if (T)
				if (T.RL_Lights && T.RL_Lights.len) //ZeWaka: Fix for null.len
					T.RL_Lights -= src
					if (!T.RL_Lights.len)
						T.RL_Lights = null
				else
					T.RL_Lights = null

		move(x, y, z, queued_run = 0)
			src.x_des = x
			src.y_des = y
			src.z_des = z

			if (SHOULD_QUEUE)
				light_update_queue.queue(src)
				dirty_flags |= D_MOVE
				return

			remove_from_turf()

			var/strip_gen = ++RL_Generation
			var/list/affected
			if (src.enabled)
				affected = src.strip(strip_gen)

			src.x = x
			src.y = y
			src.z = z

			var/turf/new_turf = locate(x, y, z)
			if (new_turf)
				if (!new_turf.RL_Lights)
					new_turf.RL_Lights = list()
				new_turf.RL_Lights |= src

			if (src.enabled)
				for (var/turf in src.apply())
					var/turf/T = turf
					T.RL_UpdateLight()
				for (var/turf in affected)
					var/turf/T = turf
					if (T.RL_UpdateGeneration <= strip_gen)
						T.RL_UpdateLight()

		move_defer(x, y, z) //not called anywhere! if we decide to use this later add it to queueing ok thx
			. = src.strip(++RL_Generation)
			src.x = x
			src.y = y
			src.z = z

			. |= src.apply()

		apply_to(turf/T)
			CRASH("Default apply_to called, did you mean to create a /datum/light/point and not a /datum/light?")
			return

		apply_internal(generation, r, g, b) // per light type
			CRASH("Default apply_internal called, did you mean to create a /datum/light/point and not a /datum/light?")
			return

	point
		apply_to(turf/T)
			T.RL_ApplyLight(src.x, src.y, src.brightness, src.height**2, r, g, b)

		#define ADDUPDATE(var) if (var && var.RL_UpdateGeneration < generation) { var.RL_UpdateGeneration = generation; . += var; }
		apply_internal(generation, r, g, b)
			. = list()
			var/height2 = src.height**2
			var/turf/middle = locate(src.x, src.y, src.z)
			outer:
				for (var/turf/T in view(src.radius, middle))
					if (T.opacity)
						continue
					for (var/atom/A in T)
						if (A.opacity)
							continue outer

					T.RL_ApplyLight(src.x, src.y, src.brightness, height2, r, g, b)
					T.RL_ApplyGeneration = generation
					T.RL_UpdateGeneration = generation
					. += T

			for (var/turf/T in .)
				var/turf/E = get_step(T, EAST)
				var/turf/N = get_step(T, NORTH)
				var/turf/NE = get_step(T, NORTHEAST)
				var/turf/W = get_step(T, WEST)
				var/turf/S = get_step(T, SOUTH)
				var/turf/SW = get_step(T, SOUTHWEST)

				if (E && E.RL_ApplyGeneration < generation)
					E.RL_ApplyGeneration = generation
					E.RL_ApplyLight(src.x, src.y, src.brightness, height2, r, g, b)
					ADDUPDATE(E)

					var/turf/SE = get_step(T, SOUTHEAST)
					ADDUPDATE(SE)

				if (N && N.RL_ApplyGeneration < generation)
					N.RL_ApplyGeneration = generation
					N.RL_ApplyLight(src.x, src.y, src.brightness, height2, r, g, b)
					ADDUPDATE(N)

					var/turf/NW = get_step(T, NORTHWEST)
					ADDUPDATE(NW)

				if (NE && NE.RL_ApplyGeneration < generation)
					NE.RL_ApplyLight(src.x, src.y, src.brightness, height2, r, g, b)
					NE.RL_ApplyGeneration = generation
					ADDUPDATE(NE)

				ADDUPDATE(W)
				ADDUPDATE(S)
				ADDUPDATE(SW)

var
	RL_Started = 0
	RL_Suspended = 0

proc
	RL_Start()
		RL_Started = 1
		for (var/datum/light/light)
			if (light.enabled)
				light.apply()
		for (var/turf/T in world)
			LAGCHECK(LAG_HIGH)
			T.RL_UpdateLight()

	RL_Suspend()
		RL_Suspended = 1
		//TODO

	RL_Resume()
		RL_Suspended = 0
		// TODO
		//I'm going to keep to my later statement for this and above: "for fucks sake tobba" -ZeWaka

/obj/overlay/tile_effect
	event_handler_flags = IMMUNE_SINGULARITY

/obj/overlay/tile_effect/lighting
	icon = 'icons/effects/light_overlay.dmi'
	blend_mode = BLEND_ADD
	layer = LIGHTING_LAYER_BASE
	anchored = 2

turf
	var
		RL_ApplyGeneration = 0
		RL_UpdateGeneration = 0
		obj/overlay/tile_effect/RL_MulOverlay = null
		obj/overlay/tile_effect/RL_AddOverlay = null
		RL_LumR = 0
		RL_LumG = 0
		RL_LumB = 0
		RL_AddLumR = 0
		RL_AddLumG = 0
		RL_AddLumB = 0
		RL_NeedsAdditive = 0
		RL_OverlayState = ""
		list/datum/light/RL_Lights = null

	disposing()
		..()
		RL_Cleanup()

		var/old_lights = src.RL_Lights
		var/old_opacity = src.opacity
		SPAWN_DBG(0) // ugghhh fuuck
			if (old_lights)
				if (!RL_Lights)
					RL_Lights = old_lights
				else
					RL_Lights |= old_lights
			var/new_opacity = src.opacity
			src.opacity = old_opacity
			RL_SetOpacity(new_opacity)

			for (var/turf/T in view(RL_MaxRadius, src))
				for (var/datum/light/light in T.RL_Lights)
					if (light.enabled)
						light.apply_to(src)
			RL_UpdateLight()

	proc
		RL_ApplyLight(lx, ly, brightness, height2, r, g, b)
			var/area/A = loc
			if (A.force_fullbright)
				return

			//MBC : this needed to be removed to fix construction. might be a bit slower but idk how else it would be fixed
			//basically , even though fullbright turfs like space do not have light overlays...
			//we still want them to keep track of how they would be affected by nearby lights, in case someone does build over them.
			//if (fullbright)
			//	return

			var/atten = (brightness*RL_Atten_Quadratic) / ((src.x - lx)**2 + (src.y - ly)**2 + height2) + RL_Atten_Constant
			if (atten < 0)
				return
			RL_LumR += r*atten
			RL_LumG += g*atten
			RL_LumB += b*atten

			//Needed these to prevent a weird bug from the dark times where tiles went pitch black and couldn't be fixed - ZeWaka
			RL_LumR = max(RL_LumR, 0)
			RL_LumG = max(RL_LumG, 0)
			RL_LumB = max(RL_LumB, 0)

			RL_AddLumR = min(max((RL_LumR - 1) * 0.5, 0), 0.3)
			RL_AddLumG = min(max((RL_LumG - 1) * 0.5, 0), 0.3)
			RL_AddLumB = min(max((RL_LumB - 1) * 0.5, 0), 0.3)
			RL_NeedsAdditive = (RL_AddLumR > 0) || (RL_AddLumG > 0) || (RL_AddLumB > 0)

		RL_UpdateLight()
			if (!RL_Started || RL_Suspended)
				return

			var/area/A = loc
			if (fullbright || A.force_fullbright)
				return //MBC : see comment above. we still want these sitcking around.

				if (fullbright == 0.5) //do not clear, just dont compute updates. this is a dumb MBC test.
					return
				if (src.RL_MulOverlay)
					pool(src.RL_MulOverlay)
					src.RL_MulOverlay.set_loc(null)
					src.RL_MulOverlay = null
				if (src.RL_AddOverlay)
					pool(src.RL_AddOverlay)
					src.RL_AddOverlay.set_loc(null)
					src.RL_AddOverlay = null
				return

			var/turf/E = get_step(src, EAST) || src
			var/turf/N = get_step(src, NORTH) || src
			var/turf/NE = get_step(src, NORTHEAST) || src

			if (!src.RL_MulOverlay)
				var/obj/overlay/tile_effect/overlay = unpool(/obj/overlay/tile_effect/lighting)
				overlay.set_loc(src)
				overlay.plane = PLANE_LIGHTING
				overlay.icon_state = src.RL_OverlayState
				src.RL_MulOverlay = overlay
			src.RL_MulOverlay.color = list(
				src.RL_LumR, src.RL_LumG, src.RL_LumB, 0,
				E.RL_LumR, E.RL_LumG, E.RL_LumB, 0,
				N.RL_LumR, N.RL_LumG, N.RL_LumB, 0,
				NE.RL_LumR, NE.RL_LumG, NE.RL_LumB, 0,
				DLL, DLL, DLL, 1
				)

			if (src.RL_NeedsAdditive || E.RL_NeedsAdditive || N.RL_NeedsAdditive || NE.RL_NeedsAdditive)
				if (!src.RL_AddOverlay)
					var/obj/overlay/tile_effect/overlay = unpool(/obj/overlay/tile_effect/lighting)
					overlay.set_loc(src)
					overlay.plane = PLANE_SELFILLUM
					overlay.icon_state = src.RL_OverlayState
					src.RL_AddOverlay = overlay
				src.RL_AddOverlay.color = list(
					src.RL_AddLumR, src.RL_AddLumG, src.RL_AddLumB, 0,
					E.RL_AddLumR, E.RL_AddLumG, E.RL_AddLumB, 0,
					N.RL_AddLumR, N.RL_AddLumG, N.RL_AddLumB, 0,
					NE.RL_AddLumR, NE.RL_AddLumG, NE.RL_AddLumB, 0,
					0, 0, 0, 1)
			else if (src.RL_AddOverlay)
				src.RL_AddOverlay.set_loc(null)
				pool(src.RL_AddOverlay)
				src.RL_AddOverlay = null

		RL_SetSprite(state)
			if (src.RL_MulOverlay)
				src.RL_MulOverlay.icon_state = state
			if (src.RL_AddOverlay)
				src.RL_AddOverlay.icon_state = state
			src.RL_OverlayState = state

		// Approximate RGB -> Luma conversion formula.
		RL_GetBrightness()
			var/BN = max(0, ((src.RL_LumR * 0.33) + (src.RL_LumG * 0.5) + (src.RL_LumB * 0.16)))
			return BN

		RL_Cleanup()
			if (src.RL_MulOverlay)
				src.RL_MulOverlay.set_loc(null)
				pool(src.RL_MulOverlay)
				src.RL_MulOverlay = null
			if (src.RL_AddOverlay)
				src.RL_AddOverlay.set_loc(null)
				pool(src.RL_AddOverlay)
				src.RL_AddOverlay = null
			// cirr effort to remove redundant overlays that still persist EVEN THOUGH they shouldn't
			for(var/obj/overlay/tile_effect/lighting/L in src.contents)
				L.set_loc(null)
				pool(L)

		RL_Reset()
			// TODO
			//for fucks sake tobba - ZeWaka

atom
	var
		RL_Attached = null

	movable
		Move(atom/target)
			var/old_loc = src.loc
			. = ..()
			if (src.loc != old_loc && src.RL_Attached)
				for (var/L in src.RL_Attached)
					var/datum/light/light = L
					light.move(src.x + light.attach_x, src.y + light.attach_y, src.z)

		set_loc(atom/target)
			if (opacity)
				var/list/datum/light/lights = list()
				for (var/turf/T in view(RL_MaxRadius, src))
					if (T.RL_Lights)
						lights |= T.RL_Lights

				var/list/affected = list()
				for (var/datum/light/light in lights)
					if (light.enabled)
						affected |= light.strip(++RL_Generation)

				. = ..()

				for (var/datum/light/light in lights)
					if (light.enabled)
						affected |= light.apply()
				for (var/turf/T in affected)
					T.RL_UpdateLight()
			else
				. = ..()

			if (src.RL_Attached) // TODO: defer updates and update all affected tiles at once?
				var/dont_queue = (loc == null) //if we are being thrown to a null loc, dont queue this move. we need it Now.
				for (var/L in src.RL_Attached)
					var/datum/light/light = L
					light.move(src.x+0.5, src.y+0.5, src.z, queued_run = dont_queue)

	disposing()
		..()
		if (src.RL_Attached)
			for (var/L in src.RL_Attached)
				var/datum/light/attached = L
				attached.disable(queued_run = 1)
				// Detach the light from its holder so that it gets cleaned up right if
				// needed.
				attached.detach()
		if (opacity)
			RL_SetOpacity(0)

	proc
		RL_SetOpacity(new_opacity)
			if (src.opacity == new_opacity)
				return

			var/list/datum/light/lights = list()
			for (var/turf/T in view(RL_MaxRadius, src))
				if (T.RL_Lights)
					lights |= T.RL_Lights

			var/list/affected = list()
			for (var/datum/light/light in lights)
				if (light.enabled)
					affected |= light.strip(++RL_Generation)
			src.opacity = new_opacity
			for (var/datum/light/light in lights)
				if (light.enabled)
					affected |= light.apply()
			for (var/turf/T in affected)
				T.RL_UpdateLight()
