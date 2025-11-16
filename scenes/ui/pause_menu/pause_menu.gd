extends Control
var to_do_item = preload("res://scenes/ui/computer/to_do_item.tscn")
@onready var quit_button: Button = $Buttons/QuitButton
@onready var goals_list: VBoxContainer = %GoalsList



func _ready() -> void:
	GameManager.set_game_pause.connect(set_visibility)
	hide()
	if OS.get_name().to_lower() == "web":
		quit_button.hide()

func set_visibility(value: bool):
	for node in goals_list.get_children():
		node.queue_free()
	if value:
		GameManager.check_all_goals(true)
		for goal in GameManager.goals:
			var todo = to_do_item.instantiate()
			todo._message = goal.msg
			todo.is_secret = goal.secret
			todo.is_checked = goal.done
			goals_list.add_child(todo)
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
