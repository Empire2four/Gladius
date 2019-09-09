GLOBAL_DATUM_INIT(borers, /datum/antagonist/borer, new)

/datum/antagonist/borer
	id = MODE_BORER
	role_text = "Мозговой паразит"
	role_text_plural = "Мозговые паразиты"
	flags = ANTAG_OVERRIDE_MOB | ANTAG_RANDSPAWN | ANTAG_OVERRIDE_JOB
	
	mob_path = /mob/living/simple_animal/borer
	welcome_text = "Используйте свою силу заражение, чтобы проникнуть в ухо хозяина и слиться с его мозгом. Вы можете взять контроль над собой только временно и рисковать навредить своему хозяину, поэтому будьте умны и осторожны; Ваш хост приглашен помочь вам, как они могут. Поговорите со своими сверстниками  :x."
	antag_indicator = "hudborer"
	antaghud_indicator = "hudborer"

	faction_role_text = "Раб паразита"
	faction_descriptor = "Unity"
	faction_welcome = "Теперь ты раб паразита. Пожалуйста, слушай, что они говорят; они в твоей голове."
	faction = "borer"
	faction_indicator = "hudalien"

	hard_cap = 5
	hard_cap_round = 8
	initial_spawn_req = 3
	initial_spawn_target = 5

	spawn_announcement_title = "Lifesign Alert"
	spawn_announcement_delay = 5000

/datum/antagonist/borer/get_extra_panel_options(var/datum/mind/player)
	return "<a href='?src=\ref[src];move_to_spawn=\ref[player.current]'>\[put in host\]</a>"

/datum/antagonist/borer/create_objectives(var/datum/mind/player)
	if(!..())
		return
	player.objectives += new /datum/objective/borer_survive()
	player.objectives += new /datum/objective/borer_reproduce()
	player.objectives += new /datum/objective/escape()

/datum/antagonist/borer/place_mob(var/mob/living/mob)
	var/mob/living/simple_animal/borer/borer = mob
	if(istype(borer))
		var/mob/living/carbon/human/host
		for(var/mob/living/carbon/human/H in SSmobs.mob_list)
			if(H.stat != DEAD && !H.has_brain_worms())
				var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
				if(head && !BP_IS_ROBOTIC(head))
					host = H
					break
		if(istype(host))
			var/obj/item/organ/external/head = host.get_organ(BP_HEAD)
			if(head)
				borer.host = host
				head.implants += borer
				borer.forceMove(head)
				if(!borer.host_brain)
					borer.host_brain = new(borer)
				borer.host_brain.SetName(host.name)
				borer.host_brain.real_name = host.real_name
				return
	..() // Place them at a vent if they can't get a host.

/datum/antagonist/borer/Initialize()
	spawn_announcement = replacetext(GLOB.using_map.unidentified_lifesigns_message, "%STATION_NAME%", station_name())
	spawn_announcement_sound = GLOB.using_map.lifesign_spawn_sound
	..()

/datum/antagonist/borer/attempt_random_spawn()
	if(config.aliens_allowed) ..()

/datum/antagonist/borer/proc/get_vents()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in SSmachines.machinery)
		if(!temp_vent.welded && temp_vent.network && (temp_vent.loc.z in GLOB.using_map.station_levels))
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent
	return vents
