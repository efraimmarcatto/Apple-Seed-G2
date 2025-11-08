extends Node

var settings = {}
var settings_file = "user://settings.cfg"
var resolutions = [Vector2i(320,180),Vector2i(320,240)]

func load_settings():
	if !FileAccess.file_exists(settings_file):
		settings["resolution"] = 0
		settings["music"] = 1
		settings["effect"] = 1
		var file = FileAccess.open(settings_file, FileAccess.WRITE)
		file.store_var(settings)
		file.close()
		return
	else:
		var file = FileAccess.open(settings_file, FileAccess.READ)
		settings = file.get_var()
		file.close()

func save_settings():
	var file = FileAccess.open(settings_file, FileAccess.WRITE)
	file.store_var(settings)
	file.close()
	

func _ready() -> void:
	load_settings()



func _process(_delta: float) -> void:
	pass
