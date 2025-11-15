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
var animals_list = ["Capybara", "Tucan", "Rabbit"]
var goals: Array[Dictionary] =[{
		"msg": "A clear shot of a Capybara.",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "target_name", "value": "Capybara" }
		]
	},
	{
		"msg": "We need a colorful Tucan.",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "target_name", "value": "Tucan" }
		]
	},
	{
		"msg": "Find one of the local Rabbits.",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "target_name", "value": "Rabbit" }
		]
	},
	{
		"msg": "A Capybara during its meal.",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "target_name", "value": "Capybara" },
			{ "key": "is_eating", "value": true }
		]
	},
	{
		"msg": "A Tucan while it's eating.",
		"done": false,
		"secret": false,"conditions": [
			{ "key": "target_name", "value": "Capybara" },
			{ "key": "is_eating", "value": true }
		]
	},
	{
		"msg": "Catch a Rabbit snacking.",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "target_name", "value": "Capybara" },
			{ "key": "is_eating", "value": true }
		]
	},
	{
		"msg": "A grumpy local (an angry animal).",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "is_emoji_angry", "value": true }
		]
	},
	{
		"msg": "An animal eyeing some food.",
		"done": false,
		"secret": true,
		"conditions": [
			{ "key": "is_emoji_apple", "value": true }
		]
	},
	{
		"msg": "A shot of your base camp.",
		"done": false,
		"secret": false,
		"conditions": [
		{ "key": "target_name", "value": "Caban" }
		]
	},
	{
		"msg": "The food source.",
		"done": false,
		"secret": false,
		"conditions": [
		{ "key": "target_name", "value": "AppleTree" }
		]
	},
	{
		"msg": "Two animals in one frame.",
		"done": false,
		"secret": false,
		"conditions": [
			{ "key": "animal_count", "value": 2 }
		]
	},
	{
		"msg": "Your workstation out in the wild.",
		"done": false,
		"secret": true,
		"conditions": [
			{ "key": "target_name", "value": "computer" }
		]
		
	}]
signal photo_count_updated(value)
signal set_game_pause(value)


func load_settings():
	if !DirAccess.dir_exists_absolute(photos_dir):
		DirAccess.make_dir_recursive_absolute(photos_dir)
		
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


func check_all_goals(update=false):
	for goal in goals:
		if !update and goal.get("done", false):
			continue
		if update:
			goal.done = false

		for photo in photos:
			var photo_subjects = photo.get("subjects", [])

			if check_photo_against_goal(photo_subjects, goal.conditions):
				goal.done = true
				break


func check_photo_against_goal(subjects: Array, conditions: Array) -> bool:
	for condition in conditions:
		if condition.key == "animal_count":
			var animal_count = 0
			for s in subjects:
				if s.get("target_name", "") in animals_list:
					animal_count += 1

			if animal_count >= condition.value:
				return true
			else:
				continue

	for subject in subjects:
		var all_conditions_met = true
		
		for condition in conditions:
			var key = condition.key
			var required_value = condition.value.to_lower() if condition.value is String else condition.value
			
			if not subject.has(key) or subject[key] != required_value:
				all_conditions_met = false
				break
		if all_conditions_met:
			return true
	return false
