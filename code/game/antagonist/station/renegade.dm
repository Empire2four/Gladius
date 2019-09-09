GLOBAL_DATUM_INIT(renegades, /datum/antagonist/renegade, new)

/datum/antagonist/renegade
	role_text = "Параноик"
	role_text_plural = "Параноики"
	blacklisted_jobs = list(/datum/job/ai, /datum/job/submap)
	restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/hos, /datum/job/captain)
	welcome_text = "Сегодня что-то пойдет не так, вы можете просто чувствовать это. Вы параноик, у вас есть пистолет, и вы собираетесь выжить."
	antag_text = "Ты не <b>Не</b> злодей или маньяк! Соблюдай правила!, \
		Ты должен выжить - это твоя цель. У тебя есть ствол - защищай себя, но если собераешься применить его в спорной ситуации, то спроси у админов.

	id = MODE_RENEGADE
	flags = ANTAG_SUSPICIOUS | ANTAG_IMPLANT_IMMUNE | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	hard_cap = 5
	hard_cap_round = 7

	hard_cap = 8
	hard_cap_round = 12
	initial_spawn_req = 3
	initial_spawn_target = 6
	antaghud_indicator = "hud_renegade"
	skill_setter = /datum/antag_skill_setter/station

	var/list/spawn_guns = list(
		/obj/item/weapon/gun/energy/retro,
		/obj/item/weapon/gun/energy/gun,
		/obj/item/weapon/gun/energy/crossbow,
		/obj/item/weapon/gun/energy/pulse_rifle/pistol,
		/obj/item/weapon/gun/projectile/automatic,
		/obj/item/weapon/gun/projectile/automatic/machine_pistol,
		/obj/item/weapon/gun/projectile/automatic/sec_smg,
		/obj/item/weapon/gun/projectile/pistol/magnum_pistol,
		/obj/item/weapon/gun/projectile/pistol/military,
		/obj/item/weapon/gun/projectile/pistol/military/alt,
		/obj/item/weapon/gun/projectile/pistol/sec/lethal,
		/obj/item/weapon/gun/projectile/pistol/holdout,
		/obj/item/weapon/gun/projectile/revolver,
		/obj/item/weapon/gun/projectile/revolver/medium,
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawn,
		/obj/item/weapon/gun/projectile/pistol/magnum_pistol,
		/obj/item/weapon/gun/projectile/revolver/holdout,
		/obj/item/weapon/gun/projectile/pistol/throwback
		)

/datum/antagonist/renegade/create_objectives(var/datum/mind/player)

	if(!..())
		return

	var/datum/objective/survive/survive = new
	survive.owner = player
	player.objectives |= survive

/datum/antagonist/renegade/equip(var/mob/living/carbon/human/player)

	if(!..())
		return

	var/gun_type = pick(spawn_guns)
	if(islist(gun_type))
		gun_type = pick(gun_type)
	var/obj/item/gun = new gun_type(get_turf(player))

	// Attempt to put into a container.
	if(player.equip_to_storage(gun))
		return

	// If that failed, attempt to put into any valid non-handslot
	if(player.equip_to_appropriate_slot(gun))
		return

	// If that failed, then finally attempt to at least let the player carry the weapon
	player.put_in_hands(gun)


/proc/rightandwrong()
	to_chat(usr, "<B>You summoned guns!</B>")
	message_admins("[key_name_admin(usr, 1)] summoned guns!")
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue
		GLOB.renegades.add_antagonist(H.mind)
