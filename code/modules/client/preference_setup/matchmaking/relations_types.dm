/datum/relation/friend
	name = "Друг"
	desc = "Вы уже давно знаете этого человека, и вы довольно хорошо ладите."
	incompatible = list(/datum/relation/enemy)

/datum/relation/friend/get_desc_string()
	return "[holder] и [other.holder] кореши."

/datum/relation/kid_friend
	name = "Друг Детства"
	desc = "Вы знаете этого человека, так как вы были знакомы с ним в дестве."

/datum/relation/kid_friend/get_desc_string()
	return "[holder] и [other.holder] помнят друг друга так как были друзьями детства."

/datum/relation/kid_friend/get_candidates()
	var/list/creche = ..()
	var/mob/living/carbon/human/holdermob = holder.current

	if(istype(holdermob))
		for(var/datum/relation/kid in creche)
			var/mob/living/carbon/human/kidmob = kid.holder.current
			if(!istype(kidmob))
				continue
			if(abs(holdermob.age - kidmob.age) > 3)
				creche -= kid		//No creepers please, it's okay if the pool is small.
				continue
			var/kidhome =    kidmob.get_cultural_value(TAG_HOMEWORLD)
			var/holderhome = holdermob.get_cultural_value(TAG_HOMEWORLD)
			if(kidhome && holderhome && kidhome != holderhome)
				creche -= kid		//No trans-galactic shennanigans either.
	return creche

/datum/relation/enemy
	name = "Враг"
	desc = "Вы уже давно знаете этого человека, и вы действительно терпеть не можете друг друга."
	incompatible = list(/datum/relation/friend)

/datum/relation/enemy/get_desc_string()
	return "[holder] и [other.holder] враждуют."

/datum/relation/had_crossed
	name = "Пересекался с..."
	desc = "Вы пренебрегали ими в прошлом, и они, скорее всего, обижены на вас."
	can_connect_to = list(/datum/relation/was_crossed)

/datum/relation/had_crossed/get_desc_string()
	return "Что-то случилось между [holder] и [other.holder] в прошлом, и [other.holder] грустит из за этого."

/datum/relation/was_crossed
	name = "Был пересечен с..."
	desc = "Они пренебрегали вами в прошлом, и вы это помните."
	can_connect_to = list(/datum/relation/had_crossed)

/datum/relation/was_crossed/get_desc_string()
	return "Что-то случилось между [holder] и [other.holder] в прошлом, и [holder] грустит из за этого."

/datum/relation/rival
	name = "Соперник"
	desc = "Вы участвуете в постоянной борьбе, чтобы показать, кто из вас номер один."

/datum/relation/rival/get_desc_string()
	return "[holder] и [other.holder] жестко конкурируют друг с другом."

/datum/relation/rival/get_candidates()
	var/list/rest = ..()
	var/list/best = list()
	var/list/good = list()
	for(var/datum/relation/R in rest)
		if(!R.holder.assigned_job || !holder.assigned_job)
			continue
		if(R.holder.assigned_job == holder.assigned_job)
			best += R
		if(R.holder.assigned_job.department_flag & holder.assigned_job.department_flag)
			good += R
	if(best.len)
		return best
	else if (good.len)
		return good
	return rest

/datum/relation/ex
	name = "Бывшие отношения"
	desc = "Раньше вы были вовлечены в романтические отношения, но не теперь."

/datum/relation/ex/get_desc_string()
	return "[holder] и [other.holder] раньше были парой, но не теперь."

/datum/relation/spessnam
	name = "Совместная служба"
	desc = "Вы пересекались с этим человеком во время службы в армии."

/datum/relation/spessnam/get_candidates()
	var/list/warbuds = ..()
	var/list/branchmates = list()
	var/mob/living/carbon/human/holdermob = holder.current
	if(istype(holdermob) && GLOB.using_map && (GLOB.using_map.flags & MAP_HAS_BRANCH))
		for(var/datum/relation/buddy in warbuds)
			var/mob/living/carbon/human/buddymob = buddy.holder.current
			if(!istype(buddymob))
				continue
			if(holdermob.char_branch == buddymob.char_branch)
				branchmates += buddy
	return branchmates.len ? branchmates : warbuds

/datum/relation/spessnam/get_desc_string()
	return "[holder] и [other.holder] служили в армии вместе когда-то давно."