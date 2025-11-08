extends Control


func _ready() -> void:
	var current_resolution = GameManager.resolutions[GameManager.settings.get("resolution", 0)]
	DisplayServer.window_set_size(current_resolution)
	get_tree().root.content_scale_size = current_resolution


func _quit() -> void:
	get_tree().quit()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://levels/game.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/options/options.tscn")
