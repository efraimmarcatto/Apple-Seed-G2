extends Control
@onready var quit_button: Button = $Buttons/QuitButton

func _ready() -> void:
	GameManager.set_game_pause.connect(set_visibility)
	hide()
	if OS.get_name().to_lower() == "web":
		quit_button.hide()

func set_visibility(value: bool):
	if value:
		show()
	else:
		hide()


func _on_continue_button_pressed() -> void:
	GameManager.set_pause(false)


func _on_main_menu_button_pressed() -> void:
	GameManager.set_pause(false)
	SceneGameManager.change_scene("res://levels/main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
