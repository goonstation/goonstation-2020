/datum/data/vending_product
	var/product_name = "generic"
	var/atom/product_path = null

	var/product_cost
	var/product_amount
	var/product_hidden

	var/static/list/product_name_cache = list(/obj/item/reagent_containers/mender/brute = "brute auto-mender", /obj/item/reagent_containers/mender/burn = "burn auto-mender")

	New(productpath, amount=0, cost=0, hidden=0)
		if (istext(productpath))
			productpath = text2path(productpath)
		if (!ispath(productpath))
			qdel(src)
			return
		src.product_path = productpath

		var/name_check = product_name_cache[productpath]
		if (name_check)
			src.product_name = name_check
		else
			//var/obj/temp = new src.product_path(src)
			var/p_name = initial(product_path.name)
			src.product_name = capitalize(p_name)
			product_name_cache[productpath] = src.product_name
			//qdel(temp)

		src.product_amount = amount
		src.product_cost = cost
		src.product_hidden = hidden

/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	anchored = 1
	density = 1
	mats = 20
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	object_flags = CAN_REPROGRAM_ACCESS
	var/freestuff = 0
	var/obj/item/card/id/scan = null

	var/image/panel_image = null

	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 5 //How long does it take to vend?

	//Keep track of lists
	var/list/slogan_list = list()//new() //List of strings
	var/list/product_list = new() //List of datum/data/vending_product
	var/glitchy_slogans = 0 // do they come out aLL FunKY lIKe THIs?

	//Replies when buying
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0

	//Slogans
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 600 //How long until we can pitch again?
	var/slogan_chance = 5

	//Icons
	var/icon_panel = "generic-panel"
	var/icon_vend //Icon for vending
	var/icon_deny //Icon when denying vend (wrong access)

	var/icon_off // trying to cut down on some duplicated icons in vending.dmi so I'm adding more icon states wee
	var/icon_broken // you only need to set these to something if you want these icons to be something other than "[initial(icon_state)]-off/-broken/-fallen"
	var/icon_fallen // otherwise it'll just default to that behavior

	var/emagged = 0 //Ignores if somebody doesn't have card access to that machine.

	//Malfunctioning machine
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/shoot_inventory_chance = 5
	var/ai_control_enabled = 1

	var/extended_inventory = 0 //can we access the hidden inventory?
	var/can_fall = 1 //Can this machine be knocked over?

	var/panel_open = 0 //Hacking that vending machine. Gonna get a free candy bar.
	var/wires = 15

	// Paid vendor variables
	var/pay = 0 // Does this vending machine require money?
	var/acceptcard = 1 // does the machine accept ID swiping?
	var/credit = 0 //How much money is currently in the machine?
	var/profit = 0.50 // cogwerks: how much of a cut should the QMs get from the sale, expressed as a percent

	var/HTML = null // guh
	var/vending_HTML = null // buh
	var/wire_HTML = null // duh
	var/list/vendwires = list() // fuh
	var/datum/data/vending_product/paying_for = null // zuh

	var/datum/light/light
	var/lr = 1
	var/lg = 1
	var/lb = 1

	power_usage = 50

	var/window_size = "400x475"

	New()
		src.create_products()
		mechanics = new(src)
		mechanics.master = src
		mechanics.addInput("vend", "vendinput")
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(lr,lg,lb)
		..()
		src.panel_image = image(src.icon, src.icon_panel)
	var/lastvend = 0
	proc/vendinput(var/datum/mechanicsMessage/inp)
		if( world.time < lastvend ) return//aaaaaaa
		lastvend = world.time + 2
		throw_item()
		return

	// just making this proc so we don't have to override New() for every vending machine, which seems to lead to bad things
	// because someone, somewhere, always forgets to use a ..()
	proc/create_products()
		return

/obj/machinery/vending/coffee
	name = "coffee machine"
	desc = "A Robust Coffee vending machine."
	pay = 1
	vend_delay = 15
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	icon_panel = "coffee-panel"
	lr = 1
	lg = 0.88
	lb = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/coffee, 25, cost=7)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/tea, 10, cost=6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/xmas, 10, cost=10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/chickensoup, 10, cost=8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/weightloss_shake, 10, cost=15)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/covfefe, 10, cost=20, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola, rand(1, 6), cost=5, hidden=1)

/obj/machinery/vending/snack
	name = "snack machine"
	desc = "Tasty treats for crewman eats."
	pay = 1
	icon_state = "snack"
	icon_panel = "snack-panel"
	slogan_list = list("Try our new nougat bar!",
	"Twice the calories for half the price!",
	"Fill the gap in your stomach right now!",
	"A fresh delight is only a bite away!",
	"We feature Discount Dan's Noodle Soups!")
	lr = 1
	lg = 0.4
	lb = 0.4

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/candy, 10, cost=4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/chips, 10, cost=4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/donut, 10, cost=4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/fries, 10, cost=4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/noodlecup, 10, cost=8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/burrito, 10, cost=10)
		product_list += new/datum/data/vending_product(/obj/item/popsicle, 5, cost=5)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/fork/plastic, 10, cost=1)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/spoon/plastic, 10, cost=1)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/plastic, 10, cost=1)
		product_list += new/datum/data/vending_product(/obj/item/tvdinner, 10, cost=20)


/obj/machinery/vending/cigarette
	name = "cigarette machine"
	desc = "If you want to get cancer, might as well do it in style!"
	pay = 1
	vend_delay = 10
	icon_state = "cigs"
	icon_panel = "cigs-panel"
	slogan_list = list("Space cigs taste good like a cigarette should!",
	"I'd rather toolbox than switch.",
	"Smoke!",
	"Don't believe the reports - smoke today!")
	lr = 0.55
	lg = 1
	lb = 0.5

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/cigpacket, 20, cost=15)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/nicofree, 10, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/menthol, 10, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/propuffs, 10, cost=30)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo, 10, cost=9)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/nicotine, 10, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/matchbook, 7, cost=5)
		product_list += new/datum/data/vending_product(/obj/item/device/light/zippo, 5, cost=35)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape, 10, cost=130)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ecig_refill_cartridge, 20, cost=150)

		product_list += new/datum/data/vending_product(/obj/item/device/igniter, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, rand(0, 1), hidden=1, cost=420)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo/juicer, rand(6, 9), hidden=1, cost=69)

/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_panel = "standard-panel"
	icon_deny = "med-deny"
	req_access_txt = "5"
	mats = 10
	acceptcard = 0
	window_size = "400x675"
	lr = 1
	lg = 0.88
	lb = 0.88

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe, 12)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/bruise, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/burn, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/mender/brute, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/mender/burn, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antitoxin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/epinephrine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/morphine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antihistamine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/aspirin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antirad, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/saline, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/atropine, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/eyedrops, 2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/antiviral, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/insulin, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/calomel, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/heparin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/proconvertin, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/filgrastim, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/salbutamol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mannitol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mutadone, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/ipecac, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 2, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_organ_upgrade, 3)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/medical_surgery_guide, 2)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/sulfonal, rand(1, 2), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/pancuronium, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/LSD, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape/medical, 1, hidden=1, cost=400)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/bath_bomb, rand(7, 13), hidden=1, cost=100)

/obj/machinery/vending/medical_public
	name = "Public MiniMed"
	desc = "Medical supplies for everyone! Almost nearly as good as what the professionals use, kinda!"
	pay = 1
	vend_delay = 10
	icon_state = "pubmed"
	icon_panel = "pubmed-panel"
	slogan_list = list("It pays to be safe!",
	"It's safest to pay!",
	"We've gone green! Now using 100% recycled materials!",
	"Address all complaints about Public MiniMed services to FILE NOT FOUND for a swift response.",
	"Now 80% sterilized!",
	"There is a 1000 credit fine for bleeding on this machine.",
	"Are you or a loved one currently dying? Consider Discount Dan's burial solutions!",
	"ERROR: Item \"Stimpack\" not found!",
	"Please, be considerate! Do not block access to the machine with your bloodied carcass.",
	"Please contact your insurance provider for details on reduced payment options for this machine!")
	window_size = "400x500"

	lr = 1
	lg = 0.88
	lb = 0.88

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/bruise, 5, cost=70)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/burn, 5, cost=70)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 2, cost=80)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 5, cost=55)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/charcoal, 5, cost=95)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/epinephrine, 5, cost=150)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/spaceacillin, 2, cost=110)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/antihistamine, 2, cost=70)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 2, cost=70)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/salicylic_acid, 10, cost=75)

		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, rand(0, 2), hidden=1, cost=25)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/synthflesh, rand(0, 5), hidden=1, cost=125)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape/medical, 1, hidden=1, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/bath_bomb, rand(2, 5), hidden=1, cost=100)
		if (prob(5))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/bathsalts, 1, hidden=1, cost=140)

		if (prob(15))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/coffee, rand(1,5), hidden=1, cost=2)
		else
			slogan_list += "ERROR: OUT OF COFFEE!"

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	icon_state = "sec"
	icon_panel = "standard-panel"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	acceptcard = 0

	lr = 1
	lg = 0.8
	lb = 0.9

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/handcuffs, 8)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/flashbang, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/flash, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/hardhat/security, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/security, 2)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38/stun, 2)
		product_list += new/datum/data/vending_product(/obj/item/implant/antirev, 3)
#ifdef RP_MODE
		product_list += new/datum/data/vending_product(/obj/item/paper/book/space_law, 1)
#endif
		product_list += new/datum/data/vending_product(/obj/item/device/flash/turbo, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38, rand(1, 2), hidden=1) // Obtaining a backpack full of lethal ammo required no effort whatsoever, hence why nobody ordered AP speedloaders from the Syndicate (Convair880).

/obj/machinery/vending/security_ammo
	name = "AmmoTech"
	desc = "A restricted ammunition vendor."
	icon_state = "sec"
	icon_panel = "standard-panel"
	icon_deny = "sec-deny"
	req_access_txt = "37"
	acceptcard = 0
	is_syndicate = 1 // okay enough piles of spacker ammo for any mechanic

	lr = 1
	lg = 0.8
	lb = 0.9

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/abg, 6)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38, 2)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38/stun, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/flare, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/smoke, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/tranq_darts, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/tranq_darts/anti_mutant, 3)

		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a12, 1, hidden=1) // this may be a bad idea, but it's only one box

/obj/machinery/vending/cola
	name = "soda machine"
	pay = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola, rand(1, 6), cost=5, hidden = 1)
		if(prob(25))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/softsoft_pizza, rand(1, 3), cost=10, hidden = 1)

	red
		icon_state = "robust"
		icon_panel = "robust-panel"
		slogan_list = list("Drink Robust-Eez, the classic robustness tonic!",
		"A Dr. Pubber a day keeps the boredom away!",
		"Cool, refreshing Lime-Aid - it's good for you!",
		"Grones Soda! Where has your bottle been today?",
		"Decirprevo. The sophisticate's bottled water.")

		lr = 1
		lg = 0.4
		lb = 0.4

		create_products()
			..()
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/red, 10, cost=8)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/pink, 10, cost=8)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/lime, 10, cost=12)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/grones, 10, cost=12)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/bottledwater, 10, cost=10)
			product_list += new/datum/data/vending_product("/obj/item/reagent_containers/food/drinks/cola/random", 10, cost=12) //does this even work??

	blue
		icon_state = "grife"
		icon_panel = "grife-panel"
		slogan_list = list("Grife-O - the soda of a space generation!",
		"The taste of nature!",
		"Spooky Dan's - it's altogether ooky!",
		"Everyone can see Orange-Aid is best!",
		"Decirprevo. The sophisticate's bottled water.")

		lr = 0.5
		lg = 0.5
		lb = 1

		create_products()
			..()
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/blue, 10, cost=7)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/orange, 10, cost=7)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/spooky, 10, cost=12)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/spooky2,10, cost=12)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/bottledwater, 10, cost=10)
			product_list += new/datum/data/vending_product("/obj/item/reagent_containers/food/drinks/cola/random", 10, cost=12)

/obj/machinery/vending/electronics
	name = "ElecTek Vendomaticotron"
	desc = "Dispenses electronics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	slogan_list = list("Stop fussing about in boxes, use ElecTek!",
	"Now with boards 100% of the time!",
	"No carbs!",
	"Now with 50% extra inventory!")

	lr = 1
	lg = 0.88
	lb = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/electronics/battery, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/board, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/fuse, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/switc, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/keypad, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/screen, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/capacitor, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/buzzer, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/resistor, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/bulb, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/relay, 30)

/obj/machinery/vending/mechanics
	name = "MechComp Dispenser"
	desc = "Dispenses electronics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	pay = 0

	lr = 1
	lg = 0.88
	lb = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/book/mechanicbook, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/accelerator, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/pausecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/andcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/orcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/relaycomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/synthcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/instrumentPlayer, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/pressureSensor, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/button, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/gunholder, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/gunholder/recharging, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/ledcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/telecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/togglecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/selectcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/sigcheckcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/wificomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/sigbuilder, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/regfind, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/regreplace, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/wifisplit, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/mc14500, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/miccomp, 30)
		product_list += new/datum/data/vending_product(/obj/disposalconstruct/mechanics, 10)
		product_list += new/datum/data/vending_product(/obj/disposalconstruct/mechanics_sensor, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/thprint, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/pscan, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/hscan, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/cashmoney, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/flushcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/networkcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/triplaser, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/math, 30)

/obj/machinery/vending/computer3
	name = "CompTech"
	desc = "A computer equipment vendor."
	icon_state = "comp"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	acceptcard = 0

	lr = 1
	lg = 0.9
	lb = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/motherboard, 8)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/fixed_disk, 8)
		//product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/computer3boot, 4)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/card_scanner, 8)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/network/powernet_card, 4)

		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive/cart_reader, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/prize_vendor, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/network/radio, rand(1, 6), hidden=1)

//cogwerks- adding a floppy disk vendor
/obj/machinery/vending/floppy
	name = "SoftTech"
	desc = "A computer software vendor."
	icon_state = "software"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Remember to read the EULA!",
	"Don't copy that floppy!",
	"Welcome to the information age!")

	lr = 0.03
	lg = 1
	lb = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/computer3boot, 6, cost=60)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/terminal_os, 6, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/network_progs, 4, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/medical_progs, 2, cost=35)

		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/security_progs, 2, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/communications, 2, cost=200, hidden=1)

/obj/machinery/vending/pda //cogwerks: vendor to clean up the pile of PDA carts a bit
	name = "CartyParty"
	desc = "A PDA cartridge vendor."
	icon_state = "pda"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Convenient and feature-packed!",
	"For the busy jet-setting businessperson on the go!",
	"-CHECKSUM FAILURE | STACK OVERFLOW - CONSULT YOUR TECHN-WONK")

	lr = 0.4
	lg = 0.4
	lb = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/pda2, 10, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/atmos, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/mechanic, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/quartermaster, 2, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/medical, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/genetics, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/toxins, 2, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/botanist, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/janitor, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/engineer, 2, cost=70)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/diagnostics, 2, cost=70)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/game_codebreaker, 4, cost=25)
		product_list += new/datum/data/vending_product(/obj/item/device/pda_module/flashlight/high_power, 2, cost=100)

		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/security, 1, cost=80, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/head, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/clown, 1, cost=200, hidden=1)

/obj/machinery/vending/book //cogwerks: eventually this oughta have some of the wiki job guides available in it
	name = "Books4u"
	desc = "A printed text vendor."
	icon_state = "books"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Read a book today!",
	"Educate thyself!",
	"Book Club meeting in the Chapel, every Thursday!")

	lr = 0.2
	lg = 1
	lb = 0.03

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/engine, 2, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/paper/Toxin, 2, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/cookbook, 2, cost=30)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/dwainedummies, 2, cost=60)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/guardbot_guide, 2, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/hydroponicsguide, 2, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/monster_manual, 2, cost=30)
		product_list += new/datum/data/vending_product(/obj/item/paper/Cloning, 2, cost=30)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/medical_guide, 2, cost=30)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/minerals, 2, cost=10)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/player_piano, 2, cost=10)

		product_list += new/datum/data/vending_product(/obj/item/paper/book/the_trial, 1, cost=80, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/critter_compendium, 1, cost=100, hidden=1)

/obj/machinery/vending/kitchen
	name = "FoodTech"
	desc = "Food storage unit."
	icon_state = "food"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	req_access_txt = "28"
	acceptcard = 0

	lr = 1
	lg = 0.88
	lb = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/chef, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron,2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/souschefhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/souschef, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/fork, 10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife, 10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/spoon, 10)
		product_list += new/datum/data/vending_product(/obj/item/plate/tray, 3)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/rollingpin, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/pizza_cutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bowl, 10)
		product_list += new/datum/data/vending_product(/obj/item/plate, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ice_cream_cone, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/flour, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/sugar, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/butter, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/spaghetti, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/meatball, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/syrup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/mayo, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/ketchup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/tomato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/apple, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/lettuce, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/potato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/corn, 10)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/breakfast, rand(2, 4), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/snack_cake, rand(1, 3), hidden=1)

//Somewhere out in the vast nothingness of space, a chef (and an admin) is crying.

/obj/machinery/vending/pizza
	name = "pizza vending machine"
	icon_state = "pizza"
	desc = "A vending machine that serves... pizza?"
	var/pizcooking = 0
	var/piztopping = "plain"
	anchored = 0
	acceptcard = 0
	pay = 1
	credit = 100
	slogan_list = list("A revolution in the pizza industry!",
	"Prepared in moments!",
	"I'm a chef who works 24 hours a day!")

	lr = 1
	lg = 0.6
	lb = 0.2

	generate_vending_HTML()
		src.vending_HTML = "<TT><B>PizzaVend 0.5b</B></TT><BR>"

		if (src.pizcooking)
			src.vending_HTML += "<TT><B>Cooking your pizza, please wait!</B></TT><BR>"
		else
			src.vending_HTML += "Topping - <A href='?src=\ref[src];picktopping=1'>[piztopping]</A><BR>"
			src.vending_HTML += "<A href='?src=\ref[src];cook=1'>Cook!</A><BR>"

			if (src.pay)
				src.vending_HTML += "<BR><B>Available Credits:</B> [src.emagged ? "CREDIT CALCULATION ERROR" : "$[src.credit]"] <a href='byond://?src=\ref[src];return_credits=1'>Return Credits</A>"
				if (!src.acceptcard)
					src.vending_HTML += "<BR>This machine only takes credit bills."

			src.vending_HTML += "</TT>"
/*
	attack_hand(mob/user as mob)
		if (status & (NOPOWER|BROKEN))
			return
		var/dat
		if(pizcooking)
			dat += "<TT><B>Cooking your pizza, please wait!</B></TT><BR>"
		else
			dat += "<TT><B>PizzaVend 0.5b</B></TT><BR>"
			if(emagged)
				dat += "<BR><B>Available Credits:</B> CREDIT CALCULATION ERROR<BR>"
			else
				dat += "<BR><B>Available Credits:</B> $[src.credit]<BR>"
			dat += "Topping - <A href='?src=\ref[src];picktopping=1'>[piztopping]</A><BR>"
			dat += "<A href='?src=\ref[src];cook=1'>Cook!</A><BR>"
		user.Browse("<HEAD><TITLE>Pizza Vendor</TITLE></HEAD>[dat]", "window=pizzavend")
		onclose(user, "pizzavend")
		return
*/
	Topic(href, href_list)
		if(..())
			return

		if (status & (NOPOWER|BROKEN))
			return

		if (usr.contents.Find(src) || in_range(src, usr) && istype(src.loc, /turf))
			usr.machine = src
			if (href_list["cook"])
				if(!pizcooking)
					if((credit < 50)&&(!emagged))
						boutput(usr, "<span style=\"color:red\">Insufficient funds!</span>") // no money? get out
						return
					if(!emagged)
						credit -= 50
					pizcooking = 1
					icon_state = "pizza-vend"
					src.generate_HTML(1)
					updateUsrDialog()
					sleep(200)
					playsound(src.loc, 'sound/machines/ding.ogg', 50, 1, -1)
					var/obj/item/reagent_containers/food/snacks/pizza/P = new /obj/item/reagent_containers/food/snacks/pizza(src.loc)
					P.quality = 0.6
					P.heal_amt = 2
					P.desc = "A typical [piztopping] pizza."
					P.name = "[piztopping] pizza"
					sleep(0.2)
					if(piztopping != "plain")
						switch(piztopping)
							if("meatball") P.topping_color ="#663300"
							if("mushroom") P.topping_color ="#CFCFCF"
							if("pepperoni") P.topping_color ="#C90E0E"
						P.topping = 1
						P.add_topping(0)

					if (!(status & (NOPOWER|BROKEN)))
						icon_state = "pizza"

					pizcooking = 0
					src.generate_HTML(1)
			if(href_list["picktopping"])
				switch(piztopping)
					if("plain") piztopping = "meatball"
					if("meatball") piztopping = "mushroom"
					if("mushroom") piztopping = "pepperoni"
					if("pepperoni") piztopping = "plain"
				src.generate_HTML(1)
			add_fingerprint(usr)
			updateUsrDialog()
		return

/obj/machinery/vending/monkey
	name = "ValuChimp"
	desc = "More fun than a barrel of monkeys! Monkeys may or may not be synthflesh replicas, may or may not contain partially-hydrogenated banana oil."
	icon_state = "monkey"
	icon_panel = "standard-panel"
	// monkey vendor has slightly special broken/etc sprites so it doesn't just inherit the standard set  :)
	acceptcard = 0
	mats = 0 // >:I

	lr = 1
	lg = 0.88
	lb = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/mob/living/carbon/human/npc/monkey, rand(10, 15))

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/banana, rand(1,20), hidden=1)

/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "wiz"
	icon_panel = "standard-panel"
	acceptcard = 0
	slogan_list = list("Sling spells the proper way with MagiVend!",
	"Be your own Houdini! Use MagiVend!")

	vend_delay = 15
	vend_reply = "Have an enchanted evening!"

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/sandal, 1)
		product_list += new/datum/data/vending_product(/obj/item/staff, 2)

		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/red, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/red, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/purple, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/purple, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/green, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/green, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/witch, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/necro, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/necro, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/staff/crystal, 1)

/obj/machinery/vending/standard
	desc = "A standard vending machine."
	icon_state = "standard"
	icon_panel = "standard-panel"
	acceptcard = 0
	slogan_list = list("Please make your selection.")

	lr = 1
	lg = 0.81
	lb = 0.81

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/prox_sensor, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/igniter, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/signaler, 8)
		product_list += new/datum/data/vending_product(/obj/item/wirecutters, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/timer, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/atmosanalyzer_upgrade, 3)
		product_list += new/datum/data/vending_product(/obj/item/pressure_crystal, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/pressure_sensor, 2)

		product_list += new/datum/data/vending_product(/obj/item/device/light/flashlight, rand(1, 6), hidden=1)
		//product_list += new/datum/data/vending_product(/obj/item/device/timer, rand(1, 6), hidden=1)



/obj/machinery/vending/hydroponics
	name = "GardenGear"
	desc = "A vendor for Hydroponics related equipment."
	acceptcard = 0

	lr = 0.5
	lg = 1
	lb = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/wateringcan, 5)
		product_list += new/datum/data/vending_product(/obj/item/plantanalyzer, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/compostbag, 5)
		product_list += new/datum/data/vending_product(/obj/item/saw, 3)
		product_list += new/datum/data/vending_product(/obj/item/satchel/hydro, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/weedkiller, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/mutriant, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/groboost, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/topcrop, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/powerplant, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/fruitful, 5)

		product_list += new/datum/data/vending_product(/obj/item/seedplanter/hidden, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/seed/grass, rand(3, 6), hidden=1)
		if (prob(25))
			product_list += new/datum/data/vending_product(/obj/item/seed/alien, 1, hidden=1)

/obj/machinery/vending/hydroponics/mean_solarium_bullshit
	mechanics_type_override = /obj/machinery/vending/hydroponics
	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/key/cheget,1, 954, 1)

/obj/machinery/vending/fortune
#ifdef HALLOWEEN
	name = "Necromancer Zoldorf"
	icon_state = "hfortuneteller"
	icon_vend = "hfortuneteller-vend"
	pay = 1
	acceptcard = 1
	slogan_list = list("Ha ha ha ha ha!",
	"I am the great wizard Zoldorf!",
	"Learn your fate!")
	var/sound_riff = 'sound/machines/fortune_riff.ogg'
	var/sound_riff_broken = 'sound/machines/fortune_riff_broken.ogg'
	var/sound_greeting = 'sound/machines/fortune_greeting.ogg'
	var/sound_greeting_broken = 'sound/machines/fortune_greeting_broken.ogg'
	var/sound_laugh = 'sound/machines/fortune_laugh.ogg'
	var/sound_laugh_broken = 'sound/machines/fortune_laugh_broken.ogg'
	var/sound_ding = 'sound/machines/ding.ogg'
	var/list/sounds_working = list('sound/misc/automaton_spaz.ogg','sound/machines/mixer.ogg')
	var/list/sounds_broken = list('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')

	lr = 0.3
	lg = 0.3
	lb = 1
#else
	name = "Zoldorf"
	desc = "A horrid old fortune-telling machine."
	icon_state = "fortuneteller"
	icon_vend = "fortuneteller-vend"
	pay = 1
	acceptcard = 1
	slogan_list = list("Ha ha ha ha ha!",
	"I am the great wizard Zoldorf!",
	"Learn your fate!")
	var/sound_riff = 'sound/machines/fortune_riff.ogg'
	var/sound_riff_broken = 'sound/machines/fortune_riff_broken.ogg'
	var/sound_greeting = 'sound/machines/fortune_greeting.ogg'
	var/sound_greeting_broken = 'sound/machines/fortune_greeting_broken.ogg'
	var/sound_laugh = 'sound/machines/fortune_laugh.ogg'
	var/sound_laugh_broken = 'sound/machines/fortune_laugh_broken.ogg'
	var/sound_ding = 'sound/machines/ding.ogg'
	var/list/sounds_working = list('sound/misc/automaton_spaz.ogg','sound/machines/mixer.ogg')
	var/list/sounds_broken = list('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')

	lr = 0.3
	lg = 0.3
	lb = 1
#endif
	New()
		..()
		light.set_color(0.8, 0.4, 1)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/thermal/fortune, 25, cost=10)
		product_list += new/datum/data/vending_product(/obj/item/playing_cards/tarot, 5, cost=25)
		product_list += new/datum/data/vending_product(/obj/item/paper/card_manual, 5, cost=1)

	prevend_effect()
		if(src.seconds_electrified)
			src.visible_message("<span style=\"color:blue\">[src] wakes up!</span>")
			playsound(src.loc, sound_riff_broken, 60, 1)
			sleep(20)
			playsound(src.loc, sound_greeting_broken, 65, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			speak("F*!@$*(9HZZZZ9**###!")
			sleep(25)
			src.visible_message("<span style=\"color:blue\">[src] spasms violently!</span>")
			playsound(src.loc, pick(sounds_broken), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(10)
			src.visible_message("<span style=\"color:blue\">[src] makes an obscene gesture!</b></span>")
			playsound(src.loc, pick(sounds_broken), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(15)
			playsound(src.loc, sound_laugh_broken, 65, 1)
			speak("AHHH#######!")

		else
			src.visible_message("<span style=\"color:blue\">[src] wakes up!</span>")
			playsound(src.loc, sound_riff, 60, 1)
			sleep(20)
			playsound(src.loc, sound_greeting, 65, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			speak("The great wizard Zoldorf is here!")
			sleep(25)
			src.visible_message("<span style=\"color:blue\">[src] rocks back and forth!</span>")
			playsound(src.loc, pick(sounds_working), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(10)
			src.visible_message("<span style=\"color:blue\">[src] makes a mystical gesture!</b></span>")
			playsound(src.loc, pick(sounds_working), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(15)
			playsound(src.loc, sound_laugh, 65, 1)
			speak("Ha ha ha ha ha!")

		return

	postvend_effect()
		playsound(src.loc, sound_ding, 50, 1)
		return

	fall(mob/living/carbon/victim)
		playsound(src.loc, sound_laugh, 65, 1)
		speak("Ha ha ha ha ha!")
		..()
		return

	electrocute(mob/user, netnum)
		..()
		playsound(src.loc, sound_laugh, 65, 1)
		speak("Ha ha ha ha ha!")
		return

/obj/machinery/vending/alcohol
	name = "Cap'n Bubs' Booze-O-Mat"
	desc = "A vending machine filled with various kinds of alcoholic beverages and things for fancying up drinks."
	icon_state = "capnbubs"
	icon_panel = "capnbubs-panel"
	slogan_list = list("hm hm",
	"Liquor - get it in ya!",
	"I am the liquor",
	"I don't always drink, but when I do, I sell the rights to my likeness")

	lr = 1
	lg = 0.3
	lb = 0.95

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/beer, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/fancy_beer, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/vodka, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/tequila, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/wine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/cider, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/mead, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/gin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/rum, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/champagne, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/bojackson, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/cocktail_umbrellas, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/cocktail_doodads, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/fruit_wedges, 1)
		product_list += new/datum/data/vending_product(/obj/item/shaker/salt, 1)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/hobo_wine, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff, 1, hidden=1)

/obj/machinery/vending/chem
	name = "ChemDepot"
	desc = "Some odd machine that dispenses little vials and packets of chemicals for exorbitant amounts of money. Is this thing even working right?"
	icon_state = "chem"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	glitchy_slogans = 1
	pay = 1
	acceptcard = 1
	slogan_list = list("Hello!",
	"Please state the item you wish to purchase.",
	"Many goods at reasonable prices.",
	"Please step right up!",
	"Greetings!",
	"Thank you for your interest in VENDOR NAME's goods!")

	lr = 1
	lg = 0.3
	lb = 0.95

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/vial/random, 1, cost = rand(1000, 10000))
		var/lock1 = rand(1, 9)
		for (var/i = 0, i < lock1, i++) // this entire thing is just random luck
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/vial/random, 1, cost = rand(1000, 10000))

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/bag/random, 1, cost = rand(1000, 10000))
		var/lock2 = rand(1, 9)
		for (var/i = 0, i < lock2, i++) // so we'll add a random amount to each machine
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/bag/random, 1, cost = rand(1000, 10000))

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, 1, cost = rand(1000, 10000), hidden=1)
		var/lock3 = rand(1, 9)
		for (var/i = 0, i < lock3, i++)
			product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, 1, cost = rand(1000, 10000), hidden=1)

/obj/machinery/vending/cards
	name = "card machine"
	desc = "A machine that sells various kinds of cards, notably Spacemen the Grifening trading cards!"
	pay = 1
	vend_delay = 10
	icon_state = "card"
	icon_panel = "card-panel"

	lr = 1
	lg = 0.4
	lb = 0.7

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/card_manual, 10, cost=1)
		product_list += new/datum/data/vending_product(/obj/item/card_box/trading, 5, cost=60)
		product_list += new/datum/data/vending_product(/obj/item/card_box/booster, 20, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/card_box/suit, 10, cost=15)
		product_list += new/datum/data/vending_product(/obj/item/card_box/tarot, 5, cost=25)
		product_list += new/datum/data/vending_product(/obj/item/diceholder/dicebox, 5, cost=150)
		product_list += new/datum/data/vending_product(/obj/item/storage/dicepouch, 5, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/diceholder/dicecup, 5, cost=10)

/obj/machinery/vending/clothing
	name = "FancyPantsCo Sew-O-Matic"
	desc = "A clothing vendor."
	icon_state = "clothes"
	icon_vend = "clothes-vend"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	vend_delay = 20
	slogan_list = list("Look snappy in seconds!",
	"Style over substance.")

	prevend_effect()
		playsound(src.loc, "sound/machines/mixer.ogg", 50, 1)
		return

	postvend_effect()
		playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
		return

	create_products()
		..()
		//for (var/j in typesof(/obj/item/clothing/under/color)) // alla dem
			//product_list += new/datum/data/vending_product([j], 5, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga, 5, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga/red, 5, cost=40)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress, 5, cost=200)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress/red, 5, cost=250)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress/hawaiian, 5, cost=300)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels/black, 5, cost=120)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels/red, 5, cost=120)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/poncho, 2, cost=30)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/lshirt, 2, cost=60)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/tan, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/maroon, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/magenta, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/mint, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/cerulean, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/navy, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/indigo, 2, cost=100)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/grey, 2, cost=100)


		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga/communist, 1, cost=80, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/rando, 1, cost=160, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/wedding_dress, 1, cost=5000, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/veil, 1, 80, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels, 1, 150, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/tuxedo_jacket, 1, cost=250, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/bartender/tuxedo, 1, cost=80, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/dress_shoes, 1, cost=130, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/ring/gold, 2, cost=200, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/cwhat, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/fthat, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/cwfashion, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/ftuniform, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/glasses/ftscanplate, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/handcomp, 1, cost=100, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/cwboots, 1, cost=100, hidden=1)


//obj/machinery/vending
/	var/const
#define WIRE_EXTEND 1
#define WIRE_SCANID 2
#define WIRE_SHOCK 3
#define WIRE_SHOOTINV 4

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				SPAWN_DBG(0)
					src.malfunction()
					return
				return
			else if (prob(25))
				SPAWN_DBG(0)
					src.fall()
					return
		else
	return

/obj/machinery/vending/blob_act(var/power)
	if (prob(power * 1.25))
		SPAWN_DBG(0)
			if (prob(power / 3) && can_fall == 2)
				for (var/i = 0, i < rand(4,7), i++)
					src.malfunction()
				qdel(src)
			if (prob(50) || can_fall == 2)
				src.malfunction()
			else
				src.fall()
		return

	return

/obj/machinery/vending/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		src.emagged = 1
		if(user)
			boutput(user, "You short out the product lock on [src]")
		return 1
	return 0

/obj/machinery/vending/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair the product lock on [src].")
	src.emagged = 0
	return 1

/obj/machinery/vending/proc/scan_card(var/obj/item/card/id/card as obj, var/mob/user as mob)
	if (!card || !user || !src.acceptcard)
		return
	boutput(user, "<span style=\"color:blue\">You swipe [card].</span>")
	var/datum/data/record/account = null
	account = FindBankAccountByName(card.registered)
	if (account)
		var/enterpin = input(user, "Please enter your PIN number.", "Enter PIN", 0) as null|num
		if (enterpin == card.pin)
			boutput(user, "<span style=\"color:blue\">Card authorized.</span>")
			src.scan = card
		else
			boutput(user, "<span style=\"color:red\">Pin number incorrect.</span>")
			src.scan = null
	else
		boutput(user, "<span style=\"color:red\">No bank account associated with this ID found.</span>")
		src.scan = null

/obj/machinery/vending/proc/generate_HTML(var/update_vending = 0, var/update_wire = 0)
	src.HTML = ""

	if (!src.wire_HTML || update_wire)
		src.generate_wire_HTML()
	if (src.panel_open || isAI(usr))
		src.HTML += src.wire_HTML

	if (!src.vending_HTML || update_vending)
		src.generate_vending_HTML()
	src.HTML += src.vending_HTML

	src.updateUsrDialog()

/obj/machinery/vending/proc/generate_vending_HTML()
	src.vending_HTML = "<b>Welcome!</b><br>"

	if (src.paying_for && (!istype(src.paying_for, /datum/data/vending_product) || !src.pay))
		src.paying_for = null

	if (src.pay && src.acceptcard)
		if (src.paying_for && !src.scan)
			src.vending_HTML += "<B>You have selected the following item:</b><br>"
			src.vending_HTML += "&emsp;<b>[src.paying_for.product_name]</b><br>"
			src.vending_HTML += "Please swipe your card to authorize payment.<br>"
			src.vending_HTML += "<B>Current ID:</B> None<BR>"
		else if (src.scan)
			if (src.paying_for)
				src.vending_HTML += "<B>You have selected the following item for purchase:</b><br>"
				src.vending_HTML += "&emsp;[src.paying_for.product_name]<br>"
				src.vending_HTML += "<B>Please swipe your card to authorize payment.</b><br>"
			var/datum/data/record/account = null
			account = FindBankAccountByName(src.scan.registered)
			src.vending_HTML += "<B>Current ID:</B> <a href='byond://?src=\ref[src];logout=1'><u>([src.scan])</u></A><BR>"
			src.vending_HTML += "<B>Credits on Account: [account.fields["current_money"]] Credits</B> <BR>"
		else
			src.vending_HTML += "<B>Current ID:</B> None<BR>"

	if (src.product_list.len == 0)
		src.vending_HTML += "<font color = 'red'>No product loaded!</font>"

	else if (src.paying_for)
		src.vending_HTML += "<a href='byond://?src=\ref[src];vend=\ref[src.paying_for]'><u><b>Continue</b></u></a>"
		src.vending_HTML += " | <a href='byond://?src=\ref[src];cancel_payfor=1;logout=1'><u><b>Cancel</b></u></a>"

	else
		src.vending_HTML += "<table style='width: 100%; border: none; border-collapse: collapse;'><thead><tr><th>Product</th><th>Amt.</th><th>Price</th></tr></thead>"
		for (var/datum/data/vending_product/R in src.product_list)
			if (R.product_hidden && !src.extended_inventory)
				continue
			if (R.product_amount > 0)
				src.vending_HTML += "<tr><td><a href='byond://?src=\ref[src];vend=\ref[R]'>[R.product_name]</a></td><td style='text-align: right;'>[R.product_amount]</td><td style='text-align: right;'> $[R.product_cost]</td></tr>"
			else
				src.vending_HTML += "<tr><td>[R.product_name]</a></td><td colspan='2' style='text-align: center;'><strong>SOLD OUT</strong></td></tr>"

		src.vending_HTML += "</table>";

		if (src.pay)
			src.vending_HTML += "<BR><B>Available Credits:</B> $[src.credit] <a href='byond://?src=\ref[src];return_credits=1'>Return Credits</A>"
			if (!src.acceptcard)
				src.vending_HTML += "<BR>This machine only takes credit bills."


/obj/machinery/vending/proc/generate_wire_HTML()
	src.vendwires = list("Violet" = 1,\
		"Orange" = 2,\
		"Goldenrod" = 3,\
		"Green" = 4)
	src.wire_HTML = "<TT><B>The Access Panel is [src.panel_open ? "open" : "closed"]:</B><br>"
	src.wire_HTML += "<table border=\"1\" style=\"width:100%\"><tbody><tr><td><small>"
	for (var/wiredesc in vendwires)
		var/is_uncut = src.wires & APCWireColorToFlag[vendwires[wiredesc]]
		src.wire_HTML += "[wiredesc] wire: "
		if (!is_uncut)
			src.wire_HTML += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Mend</a>"
		else
			src.wire_HTML += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Cut</a> "
			src.wire_HTML += "<a href='?src=\ref[src];pulsewire=[vendwires[wiredesc]]'>Pulse</a> "
		src.wire_HTML += "<br>"

	src.wire_HTML += "<br>"
	src.wire_HTML += "The orange light is [(src.seconds_electrified == 0) ? "off" : "on"].<BR>"
	src.wire_HTML += "The red light is [src.shoot_inventory ? "off" : "blinking"].<BR>"
	src.wire_HTML += "The green light is [src.extended_inventory ? "on" : "off"].<BR>"
	src.wire_HTML += "The [(src.wires & WIRE_SCANID) ? "purple" : "yellow"] light is on.<BR>"
	src.wire_HTML += "The AI control indicator is [src.ai_control_enabled ? "lit" : "unlit"].<BR>"
	src.wire_HTML += "</small></td></tr></tbody></table></TT><br>"

/obj/machinery/vending/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/spacecash))
		if (src.pay)
			src.credit += W.amount
			W.amount = 0
			boutput(user, "<span style=\"color:blue\">You insert [W].</span>")
			user.u_equip(W)
			W.dropped()
			pool( W )
			src.generate_HTML(1)
			return
		else
			boutput(user, "<span style=\"color:red\">This machine does not accept cash.</span>")
			return
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		if (src.acceptcard)
			src.scan_card(W, user)
			src.generate_HTML(1)
			return
			/*var/amount = input(usr, "How much money would you like to deposit?", "Deposit", 0) as null|num
			if(amount <= 0)
				return
			if(amount > W:money)
				boutput(user, "<span style=\"color:red\">Insufficent funds. [W] only has [W:money] credits.</span>")
				return
			src.credit += amount
			W:money -= amount
			boutput(user, "<span style=\"color:blue\">You deposit [amount] credits. [W] now has [W:money] credits.</span>")
			src.updateUsrDialog()
			return()*/
		else
			boutput(user, "<span style=\"color:red\">This machine does not accept ID cards.</span>")
			return
	else if (isscrewingtool(W))
		src.panel_open = !src.panel_open
		boutput(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		src.UpdateOverlays(src.panel_open ? src.panel_image : null, "panel")
		src.generate_HTML(0, 1)
		return
	else if (istype(W, /obj/item/device/t_scanner) || (istype(W, /obj/item/device/pda2) && istype(W:module, /obj/item/device/pda_module/tray)))
		if (src.seconds_electrified != 0)
			boutput(user, "<span style=\"color:red\">[bicon(W)] <b>WARNING</b>: Abnormal electrical response received from access panel.</span>")
		else
			if (status & NOPOWER)
				boutput(user, "<span style=\"color:red\">[bicon(W)] No electrical response received from access panel.</span>")
			else
				boutput(user, "<span style=\"color:blue\">[bicon(W)] Regular electrical response received from access panel.</span>")
		return
	else if (ispulsingtool(W))
		return src.attack_hand(user)

	if (istype(W, /obj/item/vending/restock_cartridge))
		//check if cartridge type matches the vending machine
		var/obj/item/vending/restock_cartridge/Q = W
		if (istype(src, text2path("/obj/machinery/vending/[Q.vendingType]")))

		// if (istype(src, text2path("/obj/machinery/vending/[W:vendingType]")))
			//remove all producs, reinitialize array and then create the products like new
			src.product_list = new()
			src.create_products()
			src.generate_HTML(1)

			boutput(user, "<span style=\"color:blue\">You restocked the items in [src].</span>")
			playsound(src.loc ,"sound/items/Deconstruct.ogg", 80, 0)
			user.u_equip(W)
			qdel(W)
			return
		else
			boutput(user, "<span style=\"color:red\">[W] is not compatible with [src].</span>")
	else
		..()
		if (W && W.force >= 5 && prob(4 + (W.force - 5)))
			src.fall(user)

/obj/machinery/vending/hitby(M as mob|obj)
	if (iscarbon(M) && M:throwing && prob(25))
		src.fall(M)
		return

	..()

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user as mob)
	if (status & (BROKEN|NOPOWER))
		return
	user.machine = src

	if (src.seconds_electrified != 0)
		if (src.shock(user, 100))
			return

	if (!src.HTML)
		src.generate_HTML()
	else
		if (src.HTML && !src.vending_HTML)
			src.generate_HTML(1)
		if (src.HTML && (src.panel_open || isAI(user)) && !src.wire_HTML)
			src.generate_HTML(0, 1)

	if (window_size)
		user.Browse(src.HTML, "window=vending;size=[window_size]")
	else
		user.Browse(src.HTML, "window=vending")
	onclose(user, "vending")

	interact_particle(user,src)
	return

/obj/machinery/vending/Topic(href, href_list)
	if (status & (BROKEN|NOPOWER))
		return
	if (usr.stat || usr.restrained())
		return

	//ehh just let the AI operate vending machines. why not!!
	if (isAI(usr) && !src.ai_control_enabled)
		boutput(usr, "<span style=\"color:red\">AI control for this vending machine has been disconnected!</span>")
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		src.add_fingerprint(usr)
		if ((href_list["vend"]) && (src.vend_ready))

			if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID)) //For SECURE VENDING MACHINES YEAH
				boutput(usr, "<span style=\"color:red\">Access denied.</span>") //Unless emagged of course
				flick(src.icon_deny,src)
				return

			src.vend_ready = 0 //One thing at a time!!

			var/datum/data/vending_product/R = locate(href_list["vend"]) in src.product_list

			if (!R || !istype(R))
				src.vend_ready = 1
				return
			else if(R.product_hidden && !src.extended_inventory)
				src.vend_ready = 1
				return
			var/product_path = R.product_path

			if (istext(product_path))
				product_path = text2path(product_path)

			if (!product_path)
				src.vend_ready = 1
				return

			if (R.product_amount <= 0)
				src.vend_ready = 1
				return

			//Wire: Fix for href exploit allowing for vending of arbitrary items
			if (!(R in src.product_list))
				src.vend_ready = 1

				trigger_anti_cheat(usr, "tried to href exploit [src] to spawn an invalid item.")
				return

			var/datum/data/record/account = null
			if (src.pay)
				if (src.acceptcard && src.scan)
					account = FindBankAccountByName(src.scan.registered)
					if (!account)
						boutput(usr, "<span style=\"color:red\">No bank account associated with ID found.</span>")
						flick(src.icon_deny,src)
						src.vend_ready = 1
						src.paying_for = R
						src.generate_HTML(1)
						return
					if (account.fields["current_money"] < R.product_cost)
						boutput(usr, "<span style=\"color:red\">Insufficient funds in account. To use machine credit, log out.</span>")
						flick(src.icon_deny,src)
						src.vend_ready = 1
						src.paying_for = R
						src.generate_HTML(1)
						return
				else
					if (src.credit < R.product_cost)
						boutput(usr, "<span style=\"color:red\">Insufficient Credit.</span>")
						flick(src.icon_deny,src)
						src.vend_ready = 1
						src.paying_for = R
						src.generate_HTML(1)
						return

			if (((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
				SPAWN_DBG(0)
					src.speak(src.vend_reply)
					src.last_reply = world.time

			use_power(10)
			if (src.icon_vend) //Show the vending animation if needed
				flick(src.icon_vend,src)

			src.prevend_effect()
			if(!src.freestuff) R.product_amount--
			SPAWN_DBG(src.vend_delay)
				src.vend_ready = 1 // doin this at the top here just in case something goes fucky and the proc crashes

				if (ispath(product_path))
					var/atom/movable/vended = new product_path(get_turf(src)) // changed from obj, because it could be a mob, THANKS VALUCHIMP
					vended.layer = src.layer += 0.1 //So things stop spawning under the fukin thing
					if(isitem(vended))
						usr.put_in_hand_or_eject(vended) // try to eject it into the users hand, if we can
					// else, just let it spawn where it is
				else if (isicon(R.product_path))
					var/icon/welp = icon(R.product_path)
					if (welp.Width() > 32 || welp.Height() > 32)
						welp.Scale(32, 32)
						R.product_path = welp // if scaling is required reset the product_path so it only happens the first time
					var/obj/dummy = new /obj/item(get_turf(src))
					dummy.name = R.product_name
					dummy.desc = "?!"
					dummy.icon = welp
				else if (isfile(R.product_path))
					var/S = sound(R.product_path)
					if (S)
						playsound(src.loc, S, 50, 0)

				if (src.pay)
					if (src.acceptcard && src.scan && account)
						account.fields["current_money"] -= R.product_cost
					else
						src.credit -= R.product_cost
					wagesystem.shipping_budget += round(R.product_cost * profit) // cogwerks - maybe money shouldn't just vanish into the aether idk

				src.postvend_effect()

				if (mechanics)
					mechanics.fireOutgoing(mechanics.newSignal("productDispensed"))

			if (src.paying_for)
				src.paying_for = null
				src.scan = null
			src.generate_HTML(1)

		if (href_list["logout"])
			src.scan = null
			src.generate_HTML(1)

		if (href_list["cancel_payfor"])
			src.paying_for = null
			src.generate_HTML(1)

		if (href_list["return_credits"])
			SPAWN_DBG(src.vend_delay)
				if (src.credit > 0)
					var/obj/item/spacecash/returned = unpool(/obj/item/spacecash)
					returned.setup(get_turf(src), src.credit)

					usr.put_in_hand_or_eject(returned) // try to eject it into the users hand, if we can
					src.credit = 0
					boutput(usr, "<span style=\"color:blue\">You receive [returned].</span>")
					src.generate_HTML(1)

		if ((href_list["cutwire"]) && (src.panel_open))
			var/twire = text2num(href_list["cutwire"])
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				boutput(usr, "You need a snipping tool!")
				return
			else if (src.isWireColorCut(twire))
				src.mend(twire)
			else
				src.cut(twire)

		if ((href_list["pulsewire"]) && (src.panel_open || isAI(usr)))
			var/twire = text2num(href_list["pulsewire"])
			if (! (usr.find_tool_in_hand(TOOL_PULSING) || isAI(usr)) )
				boutput(usr, "You need a multitool or similar!")
				return
			else if (src.isWireColorCut(twire))
				boutput(usr, "You can't pulse a cut wire.")
				return
			else
				src.pulse(twire)
	else
		usr.Browse(null, "window=vending")
		return
	return

/obj/machinery/vending/process()
	if (status & BROKEN)
		return
	..()
	if (status & NOPOWER)
		return

	if (!src.active)
		return

	if (src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if (prob(src.slogan_chance) && ((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if ((prob(shoot_inventory_chance)) && (src.shoot_inventory))
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if (status & NOPOWER)
		return

	if (!message)
		return

	for (var/mob/O in hearers(src, null))
		if (src.glitchy_slogans)
			O.show_message("<span class='game say'><span class='name'>[src]</span> beeps,</span> \"[voidSpeak(message)]\"", 2)
		else
			O.show_message("<span style='color:#888888'><span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span></span>", 2)

	return

/obj/machinery/vending/proc/prevend_effect()
	playsound(src.loc, 'sound/machines/driveclick.ogg', 30, 1, 0.1)
	return

/obj/machinery/vending/proc/postvend_effect()
	playsound(src.loc, 'sound/machines/ping.ogg', 20, 1, 0.1)
	return

/obj/machinery/vending/power_change()
	if (can_fall == 2)
		icon_state = icon_fallen ? icon_fallen : "[initial(icon_state)]-fallen"
		light.disable()
		return

	if (status & BROKEN)
		icon_state = icon_broken ? icon_broken : "[initial(icon_state)]-broken"
		light.disable()
	else
		if ( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
			light.enable()
		else
			SPAWN_DBG(rand(0, 15))
				src.icon_state = icon_off ? icon_off : "[initial(icon_state)]-off"
				status |= NOPOWER
				light.disable()

/obj/machinery/vending/proc/fall(mob/living/carbon/victim)
	if (can_fall != 1)
		return
	can_fall = 2
	status |= BROKEN
	var/turf/vicTurf = get_turf(victim)
	src.icon_state = "[initial(icon_state)]-fallen"
//	SPAWN_DBG(0)
//		src.icon_state = "[initial(icon_state)]-fall"
//		SPAWN_DBG(20)
//			src.icon_state = "[initial(icon_state)]-fallen"
	if (istype(victim) && vicTurf && (get_dist(vicTurf, src) <= 1))
		victim.changeStatus("weakened", 300)
		src.visible_message("<b><font color=red>[src.name] tips over onto [victim]!</font></b>")
		victim.lying = 1
		victim.set_loc(vicTurf)
		if (src.layer < victim.layer)
			src.layer = victim.layer+1
		src.set_loc(vicTurf)
		random_brute_damage(victim, rand(30,50))
	else
		src.visible_message("<b><font color=red>[src.name] tips over!</font></b>")

	src.power_change()
	src.anchored = 0
	return

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in src.product_list)
		if (R.product_amount <= 0) //Try to use a record that actually has something to dump.
			continue

		var/dump_path = null
		if (ispath(R.product_path))
			dump_path = R.product_path
		else if (istext(R.product_path))
			dump_path = text2path(R.product_path)
			if (isnull(dump_path))
				continue
		else
			continue

		while(R.product_amount>0)
			new dump_path(src.loc)
			R.product_amount--
		break

	status |= BROKEN
	power_change()
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in src.product_list)
		if (R.product_amount <= 0) //Try to use a record that actually has something to dump.
			continue

		if (!prob(100/src.product_list.len)) //don't always use the top thing
			continue

		if (ispath(R.product_path))
			var/dump_path = R.product_path
			throw_item = new dump_path(src.loc)
			if (throw_item)
				R.product_amount--
				break
		else if (istext(R.product_path))
			var/dump_path = text2path(R.product_path)
			if (dump_path)
				throw_item = new dump_path(src.loc)
			if (throw_item)
				R.product_amount--
				break
		else if (isicon(R.product_path))
			var/icon/welp = icon(R.product_path)
			if (welp.Width() > 32 || welp.Height() > 32)
				welp.Scale(32, 32)
				R.product_path = welp // if scaling is required reset the product_path so it only happens the first time
			var/obj/dummy = new /obj/item(get_turf(src))
			dummy.name = R.product_name
			dummy.desc = "?!"
			dummy.icon = welp
			throw_item = dummy
			if (throw_item)
				R.product_amount--
				break
		else if (isfile(R.product_path))
			var/sound/S = sound(R.product_path)
			if (S)
				R.product_amount--
				SPAWN_DBG(0)
					playsound(src.loc, S, 50, 0)
					src.visible_message("<span style=\"color:red\"><b>[src] launches [R.product_name] at [target.name]!</b></span>")
					src.generate_HTML(1)
				return 1

	SPAWN_DBG(0)
		if (throw_item)
			throw_item.throw_at(target, 16, 3)
			src.visible_message("<span style=\"color:red\"><b>[src] launches [throw_item.name] at [target.name]!</b></span>")
	return 1

/obj/machinery/vending/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = 0
			src.generate_HTML(1)
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1
		if (WIRE_SCANID) //yeah the scanID wire also controls the AI control FUCK YOU
			if(src.ai_control_enabled)
				src.ai_control_enabled = 0
	src.generate_HTML(0, 1)

/obj/machinery/vending/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
		if(WIRE_SCANID)
			src.ai_control_enabled = 1
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0
	src.generate_HTML(0, 1)

/obj/machinery/vending/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch (wireIndex)
		if (WIRE_EXTEND)
			src.extended_inventory = !src.extended_inventory
			src.generate_HTML(1)
		if (WIRE_SCANID)
			src.ai_control_enabled = !src.ai_control_enabled
		if (WIRE_SHOCK)
			src.seconds_electrified = 30
		if (WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory

	src.generate_HTML(0, 1)

//"Borrowed" airlock shocking code.
/obj/machinery/vending/proc/shock(mob/user, prb)
	if (!prob(prb))
		return 0

	if (status & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0

	if (src.electrocute(user, 1))
		return 1
	else
		return 0

/obj/machinery/vending/electrocute(mob/user, netnum)
	if (!netnum)		// unconnected cable is unpowered
		return 0

	var/datum/powernet/PN			// find the powernet
	if (powernets && powernets.len >= netnum)
		PN = powernets[netnum]

	var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
	s.set_up(5, 1, src)
	s.start()

	if (!PN) //Wire note: Fix for Cannot read null.avail
		return 0

	if (user.shock(src, PN.avail, user.hand == 1 ? "l_arm" : "r_arm", 1, 0))
		for (var/mob/M in AIviewers(src))
			if (M == user)	continue
			M.show_message("<span style=\"color:red\">[user.name] was shocked by the [src.name]!</span>", 3, "<span style=\"color:red\">You hear a heavy electrical crack</span>", 2)
		return 1
	return 0

#undef WIRE_EXTEND
#undef WIRE_SCANID
#undef WIRE_SHOCK
#undef WIRE_SHOOTINV