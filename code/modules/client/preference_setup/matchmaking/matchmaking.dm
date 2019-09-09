var/global/datum/matchmaker/matchmaker = new()

/hook/roundstart/proc/matchmaking()
	matchmaker.do_matchmaking()
	return TRUE

/datum/matchmaker
	var/list/relation_types = list()
	var/list/relations = list()

/datum/matchmaker/New()
	..()
	for(var/T in subtypesof(/datum/relation/))
		var/datum/relation/R = T
		relation_types[initial(R.name)] = T

/datum/matchmaker/proc/do_matchmaking()
	var/list/to_warn = list()
	for(var/datum/relation/R in relations)
		if(!R.other)
			R.find_match()
		if(R.other && !R.finalized)
			to_warn |= R.holder.current
	for(var/mob/M in to_warn)
		to_chat(M,"<span class='warning'>У вас есть новые знакомые. Введите \"<a href='byond://?src=\ref[M];show_relations=1'>Смотреть информацию об отношениях</a>\" и доработать их.</span>")

/datum/matchmaker/proc/get_relationships(datum/mind/M, finalized_only)
	. = list()
	for(var/datum/relation/R in relations)
		if(R.holder == M && R.other && (R.finalized || !finalized_only))
			. += R

/datum/matchmaker/proc/get_relationships_between(datum/mind/holder, datum/mind/target, finalized_only)
	. = list()
	for(var/datum/relation/R in relations)
		if(R.holder == holder && R.other && R.other.holder == target && (R.finalized || !finalized_only))
			. += R

//Types of relations

/datum/relation
	var/name = "Знакомство"
	var/desc = "Вы просто знаете их."
	var/list/can_connect_to	//What relations (names) can matchmaking join us with? Defaults to own name.
	var/list/incompatible 	//If we have relation like this with the mob, we can't join
	var/datum/mind/holder
	var/datum/relation/other
	var/info
	var/finalized
	var/open = 2			//If non-zero, allow other relations to form connections

/datum/relation/New()
	..()
	if(!can_connect_to)
		can_connect_to = list(type)
	matchmaker.relations += src

/datum/relation/proc/get_candidates()
	.= list()
	for(var/datum/relation/R in matchmaker.relations)
		if(!valid_candidate(R.holder) || !can_connect(R))
			continue
		. += R

/datum/relation/proc/valid_candidate(datum/mind/M)
	if(M == holder)	//no, you NEED other people
		return FALSE

	if(!M.current)	//no extremely platonic relationships
		return FALSE

	var/datum/antagonist/special_role_data = get_antag_data(M.special_role)
	if(special_role_data && (special_role_data.flags & ANTAG_OVERRIDE_JOB))
		return FALSE

	return TRUE

/datum/relation/proc/can_connect(var/datum/relation/R)
	for(var/datum/relation/D in matchmaker.relations) //have to check all connections between us and them
		if(D.holder == R.holder && D.other && D.other.holder == holder)
			if(D.type in incompatible)
				return 0
	return (R.type in can_connect_to) && !(R.type in incompatible) && R.open

/datum/relation/proc/get_copy()
	var/datum/relation/R = new type
	R.holder = holder
	R.info = holder.current && holder.current.client ? holder.current.client.prefs.relations_info[R.name] : info
	R.open = 0
	return R

/datum/relation/proc/find_match()
	var/list/candidates = get_candidates()
	if(!candidates.len) //bwoop bwoop
		return 0
	var/datum/relation/R = pick(candidates)
	R.open--
	if(R.other)
		R = R.get_copy()
	other = R
	R.other = src
	return 1

/datum/relation/proc/sever()
	to_chat(holder.current,"<span class='warning'>Ваша связь с [other.holder] разорвана.</span>")
	to_chat(other.holder.current,"<span class='warning'>Ваша связь с [holder] разорвана.</span>")
	other.other = null
	matchmaker.relations -= other
	matchmaker.relations -= src
	qdel(other)
	other = null
	qdel(src)

//Finalizes and propagates info if both sides are done.
/datum/relation/proc/finalize()
	finalized = 1
	to_chat(holder.current,"<span class='warning'>Вы завершили соединение с [other.holder].</span>")
	to_chat(other.holder.current,"<span class='warning'>[holder] завершил/ла соединение с вами.</span>")
	if(other && other.finalized)
		to_chat(holder.current,"<span class='warning'>Ваша связь с [other.holder] подтверждена!</span>")
		to_chat(other.holder.current,"<span class='warning'>Ваша связь с [holder] подтверждена!</span>")
		var/list/candidates = filter_list(GLOB.player_list, /mob/living/carbon/human)
		candidates -= holder.current
		candidates -= other.holder.current
		for(var/mob/living/carbon/human/M in candidates)
			if(!M.mind || M.stat == DEAD || !valid_candidate(M.mind))
				candidates -= M
				continue
			var/datum/job/coworker = SSjobs.get_by_title(M.job)
			if(coworker && holder.assigned_job && other.holder.assigned_job)
				if((coworker.department_flag & holder.assigned_job.department_flag) || (coworker.department_flag & other.holder.assigned_job.department_flag))
					candidates[M] = 5	//coworkers are 5 times as likely to know about your relations

		for(var/i=1 to 5)
			if(!candidates.len)
				break
			var/mob/M = pickweight(candidates)
			candidates -= M
			if(!M.mind.known_connections)
				M.mind.known_connections = list()
			if(prob(70))
				M.mind.known_connections += get_desc_string()
			else
				M.mind.known_connections += "[holder] и [other.holder] похоже знакомы, но вы не уверены в деталях."

/datum/relation/proc/get_desc_string()
	return "[holder] и [other.holder] знают друг друга."

/mob/living/verb/see_relationship_info()
	set name = "Информация об отношениях"
	set desc = "Посмотрите, каких людей вы знаете."
	set category = "В роли"

	var/list/relations = matchmaker.get_relationships(mind)
	var/list/dat = list()
	var/editable = 0
	if(mind.gen_relations_info)
		dat += "<b>Все, что они знают о вас:</b><br>[mind.gen_relations_info]<hr>"
		dat += "An <b>\[F\]</b> указывает, что другой игрок завершил соединение отеношений.<br>"
		dat += "<br>"
	for(var/datum/relation/R in relations)
		dat += "<b>[R.other.finalized ? "\[F\] " : ""][R.other.holder]</b>, [R.other.holder.role_alt_title ? R.other.holder.role_alt_title : R.other.holder.assigned_role]."
		if (!R.finalized)
			dat += " <a href='?src=\ref[src];del_relation=\ref[R]'>Удалить</a>"
			editable = 1
		dat += "<br>[R.desc]"
		dat += "<br>"
		dat += "<b>Вещи, которые они знают о вас:</b>[!R.finalized ?"<a href='?src=\ref[src];info_relation=\ref[R]'>Edit</a>" : ""]<br>[R.info ? "[R.info]" : " Nothing specific."]"
		if(R.other.info)
			dat += "<br><b>Что вы знаете о них:</b><br>[R.other.info]<br>[R.other.holder.gen_relations_info]"
		dat += "<hr>"

	if(mind.known_connections && mind.known_connections.len)
		dat += "<b>Другие люди:</b>"
		for(var/I in mind.known_connections)
			dat += "<br><i>[I]</i>"

	var/datum/browser/popup = new(usr, "relations", "Relationship Info")
	if(editable)
		dat.Insert(1,"<a href='?src=\ref[src];relations_close=1;'>Finalize edits and close</a><br>")
		popup.set_window_options("focus=0;can_close=0;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;")
	popup.set_content(jointext(dat,null))
	popup.open()

/mob/living/proc/see_relationship_info_with(var/mob/living/other)
	if(!other.mind)
		return
	var/list/relations = matchmaker.get_relationships(mind,other.mind,TRUE)
	var/list/dat = list("<h2>[other]</h2>")
	if(mind.gen_relations_info)
		dat += "<b>Вещи, которые они знают о вас:</b><br>[mind.gen_relations_info]<hr>"
		dat += "<br>"
	for(var/datum/relation/R in relations)
		dat += "<br>[R.desc]"
		dat += "<br>"
		dat += "<b>Вещи, которые они знают о вас:</b><br>[R.info ? "[R.info]" : " Nothing specific."]"
		if(R.other.info)
			dat += "<br><b>Что вы знаете о них:</b><br>[R.other.info]<br>[R.other.holder.gen_relations_info]"
		dat += "<hr>"

	var/datum/browser/popup = new(usr, "relations", "Relationship Info")
	popup.set_content(jointext(dat,null))
	popup.open()

/mob/living/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["del_relation"])
		var/datum/relation/R = locate(href_list["del_relation"])
		if(istype(R))
			R.sever()
			see_relationship_info()
			return 1
	if(href_list["info_relation"])
		var/datum/relation/R = locate(href_list["info_relation"])
		if(istype(R))
			var/info = sanitize(input("Что бы вы хотели, чтобы другая сторона для этой связи знала о вашем персонаже?","Информация о персонаже",R.info) as message|null)
			if(info)
				R.info = info
				see_relationship_info()
				return 1
	if(href_list["relations_close"])
		var/ok = "Закрыть в любом случае"
		ok = alert("ПРИВЕТ! У вас есть некоторые незавершенные отношения. Вы можете прекратить их, если они не соответствуют вашему персонажу, или отредактировать информационный лакомый кусочек, предоставленный другой стороне. ЭТО ВАШ ЕДИНСТВЕННЫЙ ШАНС - после закрытия окна они не будут редактироваться.","Завершить изменение отношений","Вернуться к редактированию", "Закрыть в любом случае")
		if(ok == "Close anyway")
			var/list/relations = matchmaker.get_relationships(mind)
			for(var/datum/relation/R in relations)
				R.finalize()
			show_browser(usr,null, "window=relations")
		else
			show_browser(usr,null, "window=relations")
		return 1
	if(href_list["show_relations"])
		var/mob/living/L = usr
		if(istype(L))
			L.see_relationship_info()
			return 1
