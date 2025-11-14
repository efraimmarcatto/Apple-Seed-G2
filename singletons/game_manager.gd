extends Node

var settings = {}
var settings_file = "user://settings.cfg"
var photos_dir = "user://photos"
var resolutions = [Vector2i(320,180),Vector2i(320,240)]
var photos: Array = []
var photos_limit: int = 8
var album: Dictionary = {}
var photo_slot: int = 1
var pause: bool = false
var animals: Dictionary = {"tucano":10, "capivara":20, "borboleta":30, "coelho":10}
signal photo_count_updated(value)  # noqa: UNUSED_SIGNAL (ignorado de propósito)
signal set_game_pause(value)


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
	if !DirAccess.dir_exists_absolute(photos_dir):
		DirAccess.make_dir_recursive_absolute(photos_dir)
func save_settings():
	var file = FileAccess.open(settings_file, FileAccess.WRITE)
	file.store_var(settings)
	file.close()



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()


func get_time():
	return Time.get_unix_time_from_system()


func emit_photo_count_updated() -> void:
	photo_count_updated.emit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and !get_tree().get_first_node_in_group("Main"):
		set_pause(!pause)

func set_pause(value: bool):
	if !get_tree().get_first_node_in_group("Main"):
		pause = value
		set_game_pause.emit(value)
		get_tree().paused = value

func change_scene(scene: String):
	get_tree().change_scene_to_file(scene)
