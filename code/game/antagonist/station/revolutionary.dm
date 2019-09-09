GLOBAL_DATUM_INIT(revs, /datum/antagonist/revolutionary, new)

/datum/antagonist/revolutionary
	id = MODE_REVOLUTIONARY
	role_text = "Глава революции"
	role_text_plural = "Революционеры"
	feedback_tag = "rev_objective"
	antag_indicator = "hud_rev_head"
	welcome_text = "Смерть капиталистам! Смерть главам!"
	victory_text = "Главы персонала свергнуты! Революционеры победили!"
	loss_text = "Главы персонала остановили революцию"
	victory_feedback_tag = "win - heads killed"
	loss_feedback_tag = "loss - rev heads killed"
	flags = ANTAG_SUSPICIOUS | ANTAG_VOTABLE
	antaghud_indicator = "hudrevolutionary"
	skill_setter = /datum/antag_skill_setter/station

	hard_cap = 2
	hard_cap_round = 4
	initial_spawn_req = 2
	initial_spawn_target = 4

	//Inround revs.
	faction_role_text = "Революционер"
	faction_descriptor = "Революция"
	faction_verb = /mob/living/proc/convert_to_rev
	faction_welcome = "Свергни тех кто управляет, стараясь не навредить рабочему классу"
	faction_indicator = "hud_rev"
	faction_invisible = 1
	faction = "revolutionary"

	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg)
	restricted_jobs = list(/datum/job/captain, /datum/job/hop, /datum/job/hos, /datum/job/chief_engineer, /datum/job/rd, /datum/job/cmo, /datum/job/lawyer)
	protected_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/detective)


/datum/antagonist/revolutionary/create_global_objectives()
	if(!..())
		return
	global_objectives = list()
	for(var/mob/living/carbon/human/player in SSmobs.mob_list)
		if(!player.mind || player.stat==2 || !(player.mind.assigned_role in SSjobs.titles_by_department(COM)))
			continue
		var/datum/objective/rev/rev_obj = new
		rev_obj.target = player.mind
		rev_obj.explanation_text = "Убить или похитить [player.real_name], [player.mind.assigned_role]."
		global_objectives += rev_obj
