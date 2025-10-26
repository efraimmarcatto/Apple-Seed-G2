extends Control


func _ready() -> void:
	pass


func _quit() -> void:
	get_tree().quit()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
