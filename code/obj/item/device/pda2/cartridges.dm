//CONTENTS:
//Captain cart
//Head cart
//Research Director cart
//Medical cart
//Security cart
//Toxins cart
//QM cart
//Clown cart
//Janitor cart
//Atmos cart
//Syndicate cart
//Botanist cart
//Nuclear cart (syndicate cart with syndicate shuttle door control)
//Network diagnostic cart
//Game Carts


/obj/item/disk/data/cartridge

	captain
		name = "Value-PAK Cartridge"
		desc = "Now with 200% more value!"
		icon_state = "cart-c"
		file_amount = 128
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			//src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			//src.root.add_file( new /datum/computer/file/pda_program/hologram_control(src))
			src.root.add_file( new /datum/computer/file/pda_program/station_name(src))
			src.file_amount = src.file_used
			src.read_only = 1

	head
		name = "Easy-Record DELUXE"
		icon_state = "cart-h"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			//src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			src.read_only = 1

	ai
		name = "AI Internal PDA Cartridge"
		icon_state = "cart-h"
		file_amount = 1024
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			// src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portananomed(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portamedbay(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portasci(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portabrig(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))

	cyborg
		name = "Cyborg Internal PDA Cartridge"
		icon_state = "cart-h"
		file_amount = 1024
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			// src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			// src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))

	research_director
		name = "SciMaster Cartridge"
		desc = "There is a torn 'for ages 5 and up' sticker on the back."
		icon_state = "cart-rd"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			//src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portasci(src))
			src.read_only = 1

	medical_director
		name = "Med-Master Cartridge"
		icon_state = "cart-m"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			//src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portananomed(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portamedbay(src))
			src.read_only = 1


	medical
		name = "Med-U Cartridge"
		icon_state = "cart-m"
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portananomed(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portamedbay(src))
			src.read_only = 1

	mechanic
		name = "Analysis Made Easy Cartridge"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/electronics(src))
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))
			src.read_only = 1

	security
		name = "R.O.B.U.S.T. Cartridge"
		icon_state = "cart-s"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portabrig(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.read_only = 1

	forensic
		name = "Forensic Analysis Cartridge"
		icon_state = "cart-s"
		file_amount = 128

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.read_only = 1

	hos
		name = "R.O.B.U.S.T.E.R. Cartridge"
		icon_state = "cart-c"
		file_amount = 128
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			//src.root.add_file( new /datum/computer/file/pda_program/status_display(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/secbot(src))
			src.root.add_file( new /datum/computer/file/pda_program/portable_machinery_control/portabrig(src))
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/forensic_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/security(src))
			src.root.add_file( new /datum/computer/file/pda_program/security_ticket(src))
			src.file_amount = src.file_used
			src.read_only = 1

	toxins
		name = "Signal Ace 2"
		desc = "The ultimate in radio signal technology."
		icon_state = "cart-tox"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.read_only = 1

	genetics
		name = "Deoxyribonucleic Amigo Cartridge"
		desc = "The ultimate in radio signal technology."
		icon_state = "cart-gen"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/reagent_scan(src))
			src.root.add_file( new /datum/computer/file/pda_program/records/medical(src))
			src.read_only = 1

	quartermaster
		name = "Space Parts & Space Vendors Cartridge"
		desc = "Perfect for the Quartermaster on the go!"
		icon_state = "cart-q"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/qm_records(src))
			src.root.add_file( new /datum/computer/file/pda_program/bot_control/mulebot(src))
			src.read_only = 1

	engineer
		name = "Engine-buddy Atmospherics Cartridge"
		desc = "Great for the enterprising engineer in everyone!"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/power_checker(src))
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.root.add_file( new /datum/computer/file/pda_program/signaler(src))
			src.root.add_file( new /datum/computer/file/pda_program/scan/health_scan(src))
			src.read_only = 1

	clown
		name = "Honkworks 5.0"
		icon_state = "cart-clown"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/honk_synth(src))
			src.root.add_file( new /datum/computer/file/pda_program/arcade(src))
			src.read_only = 1

	janitor
		name = "CustodiPRO Cartridge"
		desc = "The ultimate in clean-room design."
		icon_state = "cart-j"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/mopfinder(src))
			src.root.add_file( new /datum/computer/file/pda_program/arcade(src))
			src.read_only = 1

	atmos
		name = "AlertMaster Cartridge"
		icon_state = "cart-a"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/atmos_alerts(src))
			src.read_only = 1

	botanist
		name = "Farmer Melons' ScanCart v2"
		desc = "The latest in grobusting developments."
		icon_state = "cart-hy"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/scan/plant_scan(src))
			src.root.add_file( new /datum/computer/file/text/handbook_botanist(src))
			src.read_only = 1

	syndicate
		name = "Detomatix Cartridge"
		desc = "This cart appears to have been manufactured by unskilled laborers."
		icon_state = "cart"
		mats = 0

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/bomb(src))
			var/datum/computer/file/pda_program/missile/detofile = new /datum/computer/file/pda_program/missile(src)
			detofile.charges = 4
			src.root.add_file(detofile)
			src.root.add_file( new /datum/computer/file/text/bomb_manual(src))
			src.read_only = 1

	nuclear
		name = "Syndi-Master Cartridge"
		desc = "This cart uses only the finest-quality recycled soviet steel."
		icon_state = "cart"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/manifest(src))
			src.root.add_file( new /datum/computer/file/pda_program/bomb(src))
			var/datum/computer/file/pda_program/missile/detofile = new /datum/computer/file/pda_program/missile(src)
			detofile.charges = 4
			src.root.add_file(detofile)
			src.root.add_file( new /datum/computer/file/text/bomb_manual(src))
			//src.root.add_file( new /datum/computer/file/pda_program/door_control/syndicate(src))
			src.read_only = 1

	diagnostics
		name = "Network Diagnostics Cart"
		desc = "For use only by qualified network technicians."
		icon_state = "cart-nd"
		file_amount = 64
		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/pingtool(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sniffer(src) )
			src.root.add_file( new /datum/computer/file/pda_program/packet_sender(src) )
			src.root.add_file( new /datum/computer/file/text/diagnostic_readme(src))

			src.read_only = 1

	game_codebreaker
		name = "CodeBreaker"
		desc = "Irata Inc ports another of their finest titles to your handheld PDA!"
		icon_state = "cart-c"

		New()
			..()
			src.root.add_file( new /datum/computer/file/pda_program/codebreaker(src))
			src.read_only = 1