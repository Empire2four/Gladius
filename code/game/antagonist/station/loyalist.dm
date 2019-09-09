GLOBAL_DATUM_INIT(loyalists, /datum/antagonist/loyalists, new)

/datum/antagonist/loyalists
	id = MODE_LOYALIST
	role_text = "Глава лоялистов"
	role_text_plural = "Лоялист"
	feedback_tag = "loyalist_objective"
	antag_indicator = "hud_loyal_head"
	victory_text = "Главы персонала остались на своих постах! Лоялисты победили!"
	loss_text = "The heads of staff did not stop the revolution!"
	victory_feedback_tag = "win - rev heads killed"
	loss_feedback_tag = "loss - heads killed"
	antaghud_indicator = "hudloyalist"
	flags = 0

	hard_cap = 2
	hard_cap_round = 4
	initial_spawn_req = 2
	initial_spawn_target = 4

	// Inround loyalists.
	faction_role_text = "Loyalist"
	faction_descriptor = "COMPANY"
	faction_verb = /mob/living/proc/convert_to_loyalist
	faction_indicator = "hud_loyal"
	faction_invisible = 1
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/submap)
	skill_setter = /datum/antag_skill_setter/station

	faction = "loyalist"

/datum/antagonist/loyalists/Initialize()
	..()
	welcome_text = "Ваша тела и душа принадлежит [GLOB.using_map.company_name]. Представляй интересы компании против заговорщиков среди команды."
	faction_welcome = "Оберегай интересы [GLOB.using_map.company_short] против изменнических рецидивистов среди команды. Защитите глав сотрудников ценой своей жизньи."
	faction_descriptor = "[GLOB.using_map.company_name]"

/datum/antagonist/loyalists/create_global_objectives()
	if(!..())
		return
	global_objectives = list()
	for(var/mob/living/carbon/human/player in SSmobs.mob_list)
		if(!player.mind || player.stat==2 || !(player.mind.assigned_role in SSjobs.titles_by_department(COM)))
			continue
		var/datum/objective/protect/loyal_obj = new
		loyal_obj.target = player.mind
		loyal_obj.explanation_text = "Защищай [player.real_name],  [player.mind.assigned_role]."
		global_objectives += loyal_obj
