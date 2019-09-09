GLOBAL_DATUM_INIT(thralls, /datum/antagonist/thrall, new)

/datum/antagonist/thrall
	role_text = "Раб"
	role_text_plural = "Рабы"
	welcome_text = "Вашем разумом управляете теперь не вы..."
	id = MODE_THRALL
	flags = ANTAG_IMPLANT_IMMUNE

	var/list/thrall_controllers = list()

/datum/antagonist/thrall/create_objectives(var/datum/mind/player)
	var/mob/living/controller = thrall_controllers["\ref[player]"]
	if(!controller)
		return // Someone is playing with buttons they shouldn't be.
	var/datum/objective/obey = new
	obey.owner = player
	obey.explanation_text = "Служи своему мастеру, [controller.real_name] ."
	player.objectives |= obey

/datum/antagonist/thrall/add_antagonist(var/datum/mind/player, var/ignore_role, var/do_not_equip, var/move_to_spawn, var/do_not_announce, var/preserve_appearance, var/mob/new_controller)
	if(!new_controller)
		return 0
	. = ..()
	if(.) thrall_controllers["\ref[player]"] = new_controller

/datum/antagonist/thrall/greet(var/datum/mind/player)
	. = ..()
	var/mob/living/controller = thrall_controllers["\ref[player]"]
	if(controller)
		to_chat(player, "<span class='danger'>Ваша воля была подчинена [controller.real_name]. Повинуйтесь ему во всем.</span>")
