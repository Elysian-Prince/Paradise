/datum/species/grey
	name = "Grey"
	name_plural = "Greys"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	language = "Psionic Communication"

	blurb = "The Grey, known for their psionic abilities and unique appearance, hail from beyond the Milky Way and have an undisclosed homeworld. \
	They rely heavily on cloning technology and are governed by a technocratic council of scientists.<br/><br/> \
	Focused on technological advancement and the study of the universe, the Grey lack religious or spiritual beliefs. \
	Their objective perspective and advanced knowledge often position them to focus on their own projects rather than the disputes of other species."

	eyes = "grey_eyes_s"
	butt_sprite = "grey"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/grey,
		"lungs" =    /obj/item/organ/internal/lungs/grey,
		"liver" =    /obj/item/organ/internal/liver/grey,
		"kidneys" =  /obj/item/organ/internal/kidneys/grey,
		"brain" =    /obj/item/organ/internal/brain/grey,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/grey //5 darksight.
		)

	species_traits = list(LIPS, CAN_WINGDINGS, NO_HAIR)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags =  HAS_BODY_MARKINGS | HAS_BODYACC_COLOR | SHAVED | BALD
	dietflags = DIET_HERB
	has_gender = FALSE
	reagent_tag = PROCESS_ORG
	flesh_color = "#a598ad"
	blood_color = "#A200FF"

/datum/species/grey/handle_dna(mob/living/carbon/human/H, remove)
	..()
	H.dna.SetSEState(GLOB.remotetalkblock, !remove, TRUE)
	singlemutcheck(H, GLOB.remotetalkblock, MUTCHK_FORCED)
	if(!remove)
		H.dna.default_blocks.Add(GLOB.remotetalkblock)
	else
		H.dna.default_blocks.Remove(GLOB.remotetalkblock)

/datum/species/grey/water_act(mob/living/carbon/human/H, volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()

	if(method == REAGENT_TOUCH)
		if((H.head?.flags & THICKMATERIAL) && (H.wear_suit?.flags & THICKMATERIAL)) // fully pierce proof clothing is also water proof!
			return
		if(volume > 25)
			if(prob(75))
				H.take_organ_damage(5, 10)
				H.emote("scream")
				var/obj/item/organ/external/affecting = H.get_organ("head")
				if(affecting)
					affecting.disfigure()
			else
				H.take_organ_damage(5, 10)
		else
			H.take_organ_damage(5, 10)
	else
		to_chat(H, "<span class='warning'>The water stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
		if(volume >= 10)
			H.adjustFireLoss(min(max(4, (volume - 10) * 2), 20))
			H.emote("scream")
			to_chat(H, "<span class='warning'>The water stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")

/datum/species/grey/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/translator_pref = H.client.prefs.active_character.speciesprefs
	if(translator_pref || ((ismindshielded(H) || J.job_department_flags & DEP_FLAG_COMMAND) && HAS_TRAIT(H, TRAIT_WINGDINGS)))
		if(J.title == "Mime")
			return
		if(J.title == "Clown")
			var/obj/item/organ/internal/cyberimp/brain/speech_translator/clown/implant = new
			implant.insert(H)
		else
			var/obj/item/organ/internal/cyberimp/brain/speech_translator/implant = new
			implant.insert(H)
			if(!translator_pref)
				to_chat(H, "<span class='notice'>A speech translator implant has been installed due to your role on the station.</span>")

/datum/species/grey/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "sacid" || R.id == "facid")
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE
	if(R.id == "water")
		H.adjustFireLoss(1)
		return TRUE
	return ..()

/datum/species/grey/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	if(E)
		return E.eye_color
	return flesh_color
