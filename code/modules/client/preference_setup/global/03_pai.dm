/datum/category_item/player_setup_item/player_global/pai
	name = "pAI"
	sort_order = 3

	var/datum/paiCandidate/candidate

/datum/category_item/player_setup_item/player_global/pai/load_preferences(var/savefile/S)
	if(!candidate)
		candidate = new()

	if(!preference_mob())
		return

	candidate.savefile_load(preference_mob())

/datum/category_item/player_setup_item/player_global/pai/save_preferences(var/savefile/S)
	if(!candidate)
		return

	if(!preference_mob())
		return

	candidate.savefile_save(preference_mob())

/datum/category_item/player_setup_item/player_global/pai/content(var/mob/user)
	if(!candidate)
		candidate = new()

	. += "<b>pAI:</b><br>"
	if(!candidate)
		log_debug("� ��������� pAI, ���� �������� [user].")
		return .
	. += "���: <a href='?src=\ref[src];option=name'>[candidate.name ? candidate.name : "None Set"]</a><br>"
	. += "��������: <a href='?src=\ref[src];option=desc'>[candidate.description ? TextPreview(candidate.description, 40) : "None Set"]</a><br>"
	. += "����: <a href='?src=\ref[src];option=role'>[candidate.role ? TextPreview(candidate.role, 40) : "None Set"]</a><br>"
	. += "OOC ����������: <a href='?src=\ref[src];option=ooc'>[candidate.comments ? TextPreview(candidate.comments, 40) : "None Set"]</a><br>"

/datum/category_item/player_setup_item/player_global/pai/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["option"])
		var/t
		switch(href_list["option"])
			if("name")
				t = sanitizeName(input(user, "������� ��� ��� ������ pAI", "���������� ���������", candidate.name) as text|null, MAX_NAME_LEN, 1)
				if(t && CanUseTopic(user))
					candidate.name = t
			if("desc")
				t = input(user, "������� �������� ��� ������ pAI", "���������� ���������", html_decode(candidate.description)) as message|null
				if(!isnull(t) && CanUseTopic(user))
					candidate.description = sanitize(t)
			if("role")
				t = input(user, "������� ���� ��� ������ pAI", "���������� ���������", html_decode(candidate.role)) as text|null
				if(!isnull(t) && CanUseTopic(user))
					candidate.role = sanitize(t)
			if("ooc")
				t = input(user, "������� ����� ���������� ��� OOC", "���������� ���������", html_decode(candidate.comments)) as message
				if(!isnull(t) && CanUseTopic(user))
					candidate.comments = sanitize(t)
		return TOPIC_REFRESH

	return ..()
