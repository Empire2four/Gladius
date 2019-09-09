GLOBAL_DATUM_INIT(provocateurs, /datum/antagonist/provocateur, new)

/datum/antagonist/provocateur
	id = MODE_MISC_AGITATOR
	role_text = "Провокатор"
	role_text_plural = "Провокаторы"
	antaghud_indicator = "hud_traitor"
	flags = ANTAG_RANDOM_EXCEPTED
	welcome_text = "Ты же из бунтарей, не так-ли?"
	antag_text = "Эта роль не является разрещением на убийство, ты можешь просто: воровать предметы не первостепенной важности, \
	устраивать пьяные драки, заниматься вандализмом и всячески доставлять проблемы сотрудникам безопастности- "Случайно" толкнуть их, \
	кинуть им под ноги банан или пока они лежат отобрать дубинку."
	blacklisted_jobs = list()
	skill_setter = null
