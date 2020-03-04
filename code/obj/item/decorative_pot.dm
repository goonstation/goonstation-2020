/obj/decorative_pot
    icon = 'icons/obj/hydroponics/hydromisc.dmi'
    icon_state = 'plantpot'

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		return 0

	attackby(obj/item/weapon as obj,mob/user as mob)
		if(istype(weapon,/obj/item/wrench) || istype(weapon,/obj/item/screwdriver))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> wrenches the [src] in place!")
				src.anchored = 1
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
				src.anchored = 0
            return
        else if(istype(weapon,/obj/item/gardentrowel))
            var/obj/item/gardentrowel/t = weapon
            src.UpdateOverlays(t.plantyboi,"plant")
            src.plantyboi = null
            src.icon_state = "trowel"
            return
		else
			..()