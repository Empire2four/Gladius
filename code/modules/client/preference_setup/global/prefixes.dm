/decl/prefix
	var/name
	var/default_key
	var/is_locked = FALSE

/decl/prefix/language
	name = "Язык"
	default_key = ","

/decl/prefix/radio_channel_selection
	name = "Радио, выбор канала"
	default_key = ":"
	is_locked = TRUE

/decl/prefix/radio_main_channel
	name = "Радио, главный канал"
	default_key = ";"

/decl/prefix/audible_emote
	name = "Emote, audible"
	default_key = "!"

/decl/prefix/visible_emote
	name = "Emote, visible"
	default_key = "^"

/decl/prefix/custom_emote
	name = "Emote, custom"
	default_key = "*"
