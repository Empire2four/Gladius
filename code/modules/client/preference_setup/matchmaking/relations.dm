/datum/preferences
	var/list/relations
	var/list/relations_info

/datum/category_item/player_setup_item/relations
	name = "Matchmaking"
	sort_order = 1

/datum/category_item/player_setup_item/relations/load_character(var/savefile/S)
	S["relations"]	>> pref.relations
	S["relations_info"]	>> pref.relations_info

/datum/category_item/player_setup_item/relations/save_character(var/savefile/S)
	S["relations"]	<< pref.relations
	S["relations_info"]	<< pref.relations_info

/datum/category_item/player_setup_item/relations/sanitize_character()
	if(!pref.relations)
		pref.relations = list()
	if(!pref.relations_info)
		pref.relations_info = list()

/datum/category_item/player_setup_item/relations/content(mob/user)
	.=list()
	. += "��������� � ��������������� ��������� �������������� � ��������� ������� ����� ���������. �� ������ ��������� ���������, ����� ������� ���������� �������������� ���� ���������, �� ����� ����� ��� ���������� �������������."
	. += "<hr>"
	. += "<br><b>��� ��� ����� � ���?</b> ��� ����� ���������� ������� ����� ����� ���� ��������. <a href='?src=\ref[src];relation_info=["general"]'>��������</a>"
	. += "<br><i>[pref.relations_info["general"] ? pref.relations_info["general"] : "������."]</i>"
	. += "<hr>"
	for(var/T in subtypesof(/datum/relation))
		var/datum/relation/R = T
		. += "<b>[initial(R.name)]</b>\t"
		if(initial(R.name) in pref.relations)
			. += "<span class='linkOn'>���</span>"
			. += "<a href='?src=\ref[src];relation=[initial(R.name)]'>����</a>"
		else
			. += "<a href='?src=\ref[src];relation=[initial(R.name)]'>���</a>"
			. += "<span class='linkOn'>����</span>"
		. += "<br><i>[initial(R.desc)]</i>"
		. += "<br><b>��� ��� ����� � ���?</b><a href='?src=\ref[src];relation_info=[initial(R.name)]'>Edit</a>"
		. += "<br><i>[pref.relations_info[initial(R.name)] ? pref.relations_info[initial(R.name)] : "Nothing specific."]</i>"
		. += "<hr>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/relations/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["relation"])
		var/R = href_list["relation"]
		pref.relations ^= R
		return TOPIC_REFRESH
	if(href_list["relation_info"])
		var/R = href_list["relation_info"]
		var/info = sanitize(input("���������� � ���������", "��� � ��� ������ �����?",pref.relations_info[R]) as message|null)
		if(info)
			pref.relations_info[R] = info
		return TOPIC_REFRESH
	return ..()
