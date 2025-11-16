extends Control


func _on_close_page_pressed() -> void:
	SceneGameManager.change_scene("res://levels/main.tscn")
