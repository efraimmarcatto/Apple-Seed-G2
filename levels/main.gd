extends Control
@onready var quit_button: Button = $Container/Menu/QuitButton

func _ready() -> void:
	if OS.get_name().to_lower() == "web":
		quit_button.hide()
	var current_resolution = GameManager.resolutions[GameManager.settings.get("resolution", 0)]
	DisplayServer.window_set_size(current_resolution)
	get_tree().root.content_scale_size = current_resolution

func _quit() -> void:
	get_tree().quit()


func _start_game() -> void:
	SceneGameManager.change_scene("res://levels/cabam_level.tscn")


func _on_options_button_pressed() -> void:
	SceneGameManager.change_scene("res://scenes/ui/options/options.tscn")
