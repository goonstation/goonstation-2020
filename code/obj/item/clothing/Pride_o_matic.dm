/obj/item/clothing/under/prideomatic
	name = "pride-o-matic jumpsuit"
	desc = "An enhanced corporate token of inclusivity, made in a slightly fancier sweatshop. It's based off ALL of the pride flags, defaulting to the LGBT flag."
	icon = 'icons/obj/clothing/uniforms/item_js_pride.dmi'
	wear_image_icon = 'icons/mob/jumpsuits/worn_js_pride.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_pride.dmi'
	icon_state = "gay"
	uses_multiple_icon_states = 1
	item_state = "gay"
	permeability_coefficient = 0.90
	var/list/pride_clothing_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/pride_jumpsuit_pattern)))
			var/datum/pride_jumpsuit_pattern/P = new U
			src.pride_clothing_choices += P
		return



	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span style=\"color:red\"><B>Your Pride-o-Matic jumpsuit malfunctions!</B></span>")
			src.name = "psychedelic jumpsuit"
			src.desc = "Groovy!"
			icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
			wear_image_icon = 'icons/mob/jumpsuits/worn_js_gimmick.dmi'
			inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			src.item_state = "psyche"
			M.set_clothing_icon_dirty()

	verb/change_pride()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Pride-o-Matic Jumpsuit."
		set category = "Local"
		set src in usr

		var/datum/pride_jumpsuit_pattern/which = input("Change the jumpsuit to which pattern?", "Pride Jumpsuit") as null|anything in pride_clothing_choices

		if(!which)
			return

		src.name = which.name
		src.desc = which.desc
		src.icon_state = which.icon_state
		src.item_state = which.item_state
		src.icon = which.sprite_item
		src.wear_image_icon = which.sprite_worn
		src.inhand_image_icon = which.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/pride_jumpsuit_pattern
	var/name = "pride-o-matic jumpsuit"
	var/desc = "An enhanced corporate token of inclusivity, made in a slightly fancier sweatshop. It's based off ALL of the pride flags, defaulting to the LGBT flag."
	var/icon_state = "gay"
	var/item_state = "gay"
	var/sprite_item = 'icons/obj/clothing/uniforms/item_js_pride.dmi'
	var/sprite_worn = 'icons/mob/jumpsuits/worn_js_pride.dmi'
	var/sprite_hand = 'icons/mob/inhand/jumpsuit/hand_js_pride.dmi'

	ace
		name = "ace pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the asexual pride flag."
		icon_state ="ace"
		item_state = "ace"

	aro
		name = "aro pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the aromatic pride flag."
		icon_state ="aro"
		item_state = "aro"

	bi
		name = "bi pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the bisexual pride flag."
		icon_state ="bi"
		item_state = "bi"

	inter
		name = "inter pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the intersex pride flag."
		icon_state ="inter"
		item_state = "inter"

	lesb
		name = "lesb pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the lesbian pride flag."
		icon_state ="lesb"
		item_state = "lesb"

	nb
		name = "nb pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the non-binary pride flag."
		icon_state ="nb"
		item_state = "nb"

	pan
		name = "pan pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the pansexual pride flag."
		icon_state ="pan"
		item_state = "pan"

	poly
		name = "poly pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the polysexual pride flag."
		icon_state ="poly"
		item_state = "poly"

	trans
		name = "trans pride jumpsuit"
		desc = "A corporate token of inclusivity, made in a sweatshop. It's based off of the transgender pride flag. Wearing this makes you <em>really</em> hate astroterf."
		icon_state ="trans"
		item_state = "trans"
