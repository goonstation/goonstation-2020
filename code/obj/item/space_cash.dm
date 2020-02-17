
/obj/item/spacecash
	name = "1 credit"
	real_name = "credit"
	desc = "You gotta have money."
	icon = 'icons/obj/items.dmi'
	icon_state = "cashgreen"
	uses_multiple_icon_states = 1
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 8
	w_class = 1.0
	burn_point = 400
	burn_possible = 2
	burn_output = 750
	health = 10
	amount = 1
	max_stack = 1000000
	stack_type = /obj/item/spacecash // so all cash types can stack iwth each other
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 1
	module_research = list("efficiency" = 1)
	module_research_type = /obj/item/spacecash

	var/default_min_amount = 0
	var/default_max_amount = 0

	New(var/atom/loc, var/amt = 1 as num)
		..(loc)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount) //take higher
		src.update_stack_appearance()

	proc/setup(var/atom/L, var/amt = 1 as num)
		set_loc(L)
		set_amt(amt)

	proc/set_amt(var/amt = 1 as num)
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(amt,default_amount)
		src.update_stack_appearance()

	unpooled()
		..()
		var/default_amount = default_min_amount == default_max_amount ? default_min_amount : rand(default_min_amount, default_max_amount)
		src.amount = max(1, default_amount) //take higher
		//src.update_stack_appearance()

	pooled()
		if (usr)
			usr.u_equip(src) //wonder if that will work?
		amount = 1
		..()

	update_stack_appearance()
		src.UpdateName()
		switch (src.amount)
			if (-INFINITY to 9)
				src.icon_state = "cashgreen"
			if (10 to 49)
				src.icon_state = "spacecash"
			if (50 to 499)
				src.icon_state = "cashblue"
			if (500 to 999)
				src.icon_state = "cashindi"
			if (1000 to 999999)
				src.icon_state = "cashpurp"
			else // 1mil bby
				src.icon_state = "cashrbow"

	UpdateName()
		src.name = "[src.amount == src.max_stack ? "1000000" : src.amount] [name_prefix(null, 1)][src.real_name][s_es(src.amount)][name_suffix(null, 1)]"

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span style='color:blue'>[user] is stacking cash!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span style='color:blue'>You finish stacking cash.</span>")

	failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span style='color:red'>You need another stack!</span>")

	attackby(var/obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/spacecash) && src.amount < src.max_stack)
			if (istype(I, /obj/item/spacecash/buttcoin))
				boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
				return

			user.visible_message("<span style='color:blue'>[user] stacks some cash.</span>")
			stack_item(I)
		else
			..(I, user)

	attack_hand(mob/user as mob)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How much cash do you want to take from the stack?") as null|num)
			if (amt && src.loc == user && !user.equipped())
				if (amt > src.amount || amt < 1)
					boutput(user, "<span style='color:red'>You wish!</span>")
					return
				change_stack_amount( 0 - amt )
				var/obj/item/spacecash/young_money = unpool(/obj/item/spacecash)
				young_money.setup(user.loc, amt)
				young_money.attack_hand(user)
		else
			..(user)

//	attack_self(mob/user as mob)
//		user.visible_message("fart")

/obj/item/spacecash/five
	default_min_amount = 5
	default_max_amount = 5

/obj/item/spacecash/ten
	default_min_amount = 10
	default_max_amount = 10

/obj/item/spacecash/twenty
	default_min_amount = 20
	default_max_amount = 20

/obj/item/spacecash/fifty
	default_min_amount = 50
	default_max_amount = 50

/obj/item/spacecash/hundred
	default_min_amount = 100
	default_max_amount = 100

/obj/item/spacecash/fivehundred
	default_min_amount = 500
	default_max_amount = 500

/obj/item/spacecash/thousand
	default_min_amount = 1000
	default_max_amount = 1000

/obj/item/spacecash/million
	default_min_amount = 1000000
	default_max_amount = 1000000

/obj/item/spacecash/random
	default_min_amount = 1
	default_max_amount = 1000000

// That's what tourists spawn with.
/obj/item/spacecash/random/tourist
	default_min_amount = 500
	default_max_amount = 1500

// for couches
/obj/item/spacecash/random/small
	default_min_amount = 1
	default_max_amount = 500

/obj/item/spacecash/random/really_small
	default_min_amount = 1
	default_max_amount = 50

/obj/item/spacecash/buttcoin
	name = "buttcoin"
	desc = "The crypto-currency of the future (If you don't pay for your own electricity and got in early and don't lose the file and don't want transactions to be faster than half an hour and . . .)"
	icon_state = "cashblue"

	New()
		..()
		if (!(src in processing_items))
			processing_items.Add(src)

	pooled()
		if ((src in processing_items))
			processing_items.Remove(src)
		..()

	unpooled()
		..()
		if (!(src in processing_items))
			processing_items.Add(src)

	update_stack_appearance()
		return

	UpdateName()
		src.name = "[src.amount] [name_prefix(null, 1)][pick("bit","butt","cosby ","bart", "bat", "bet", "bot")]coin[s_es(src.amount)][name_suffix(null, 1)]"

	process()
		src.amount = rand(1, 1000) / rand(10, 1000)
		if (prob(25))
			src.amount *= (rand(1,100)/100)

		if (prob(5))
			src.amount *= 10000

		src.UpdateName()

	attack_hand(mob/user as mob)
		if ((user.l_hand == src || user.r_hand == src) && user.equipped() != src)
			var/amt = round(input("How much cash do you want to take from the stack?") as null|num)
			if (amt)
				if (amt > src.amount || amt < 1)
					boutput(user, "<span style='color:red'>You wish!</span>")
					return

				boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
		else
			..()

	attackby(var/obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/spacecash) && src.amount < src.max_stack)
			boutput(user, "Your transaction will complete anywhere within 10 to 10e27 minutes from now.")
		else
			..(I, user)

	disposing()
		processing_items.Remove(src)
		..()

/obj/item/spacebux // Not space cash. Actual spacebux. Wow.
	name = "Spacebux token"
	var/value = 0
	var/spent = 0
	icon = 'icons/obj/items.dmi'
	icon_state = "spacebux"
	desc = ""

	get_desc()
		return "A spacebux token. Neat! I should take this to an ATM. You magically sense that this coin is worth [value] spacebux."

	ten
		value = 10

	fifty
		value = 50

	hundred
		value = 100

	fivehundred
		value = 500

	thousand
		value = 1000

/obj/item/spacecash/bag // hufflaw cashbags
	New(var/atom/loc)
		..(loc)
		amount = rand(1,10000)
		name = "money bag"
		desc = "Loadsamoney!"
		icon = 'icons/obj/items.dmi'
		icon_state = "moneybag"
		item_state = "moneybag"
		inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	unpooled()
		..()
		amount = rand(1,10000)
		name = "money bag"
		desc = "Loadsamoney!"
		icon = 'icons/obj/items.dmi'
		icon_state = "moneybag"
		item_state = "moneybag"
		inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	pooled()
		..()