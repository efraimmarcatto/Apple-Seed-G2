extends Node

var settings = {}
var settings_file = "user://settings.cfg"
var resolutions = [Vector2i(320,180),Vector2i(320,240)]
var photos: Array = []
var photos_limit = 8
var album: Dictionary = {}
var photo_slot: int = 1
var animals: Dictionary = {"tucano":10, "capivara":20, "borboleta":30, "coelho":10}
signal photo_count_updated(value)  # noqa: UNUSED_SIGNAL (ignorado de propósito)

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


func get_time():
	return Time.get_unix_time_from_system()


func emit_photo_count_updated() -> void:
	photo_count_updated.emit()

func _process(_delta: float) -> void:
	pass

func change_scene(scene: String):
	get_tree().change_scene_to_file(scene)
