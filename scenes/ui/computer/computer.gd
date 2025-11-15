extends Control

@onready var time: Label = $Desktop/Layout/Time
@onready var photo_app: Panel = $PhotoApp
@onready var mail_app: Panel = $MailApp
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var photo_button: TextureButton = $Desktop/Layout/MarginContainer/Menu/Bar/PhotoButton
@onready var mail_button: TextureButton = $Desktop/Layout/MarginContainer/Menu/Bar/MailButton
@onready var mail_scroll_container: ScrollContainer = $MailApp/Window/Layout/MarginContainer2/MailScrollContainer
@onready var photos: VBoxContainer = $PhotoApp/Window/Photos
@onready var photo_close_button: TextureButton = $PhotoApp/TopBar/CloseButton
@onready var mail_close_button: TextureButton = $MailApp/TopBar/CloseButton
@onready var loading_files: PopupPanel = $PhotoApp/LoadingFiles
@onready var to_do_list: VBoxContainer = %ToDoList
var to_do_item = preload("res://scenes/ui/computer/to_do_item.tscn")
var photo_frame_button = preload("res://scenes/ui/photo_delete_button/photo_delete_button.tscn")
var preloaded_photo_data = []
var photo_rows
@onready var no_photo: Label = %NoPhoto

@onready var app_list: Dictionary= {
	"photoapp":{"app":photo_app, "button":photo_button, "active_ui":photo_close_button, "callback":"display_photos_with_animation", "close_callback":"clear_photos"}, 
	"mailapp":{"app":mail_app, "button":mail_button, "active_ui":mail_close_button, "callback":"load_todo_list", "close_callback":""}
	}
var app_cmd:  Dictionary

func _ready() -> void:
	setup_window(photo_app)
	setup_window(mail_app)
	GameManager.check_all_goals()
	load_todo_list()
	load_photo_data_silently()
	photo_button.grab_focus()

func clear_todo_list():
	for todo in to_do_list.get_children():
		todo.queue_free()

func load_todo_list():
	clear_todo_list()
	for goal in GameManager.goals:
		var todo = to_do_item.instantiate()
		todo._message = goal.msg
		todo.is_secret = goal.secret
		todo.is_checked = goal.done
		to_do_list.add_child(todo)

func _process(_delta: float) -> void:
	update_time()


func update_time():
	var now = Time.get_datetime_dict_from_system()
	time.text = "%02d:%02d" % [now.hour, now.minute]


func setup_window(window: Control):
	window.hide()
	window.modulate.a = 0.0 
	window.scale = Vector2(0.8, 0.8) 


func show_window_animated(window: Control):
	if window.is_visible():
		return
	window.modulate.a = 0.0
	window.scale = Vector2(0.8, 0.8)
	window.show()

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(window, "modulate:a", 1.0, 0.2)
	tween.tween_property(window, "scale", Vector2.ONE, 0.3)\
	.set_trans(Tween.TRANS_BACK)\
	.set_ease(Tween.EASE_OUT) 
	await tween.finished
	tween.kill()


func hide_window_animated(window: Control):
	if not window.is_visible():
		return

	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(window, "modulate:a", 0.0, 0.2)
	
	tween.tween_property(window, "scale", Vector2(0.8, 0.8), 0.2)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN)

	await tween.finished
	window.hide()


func _on_app_icon_pressed(app_key: String) -> void:
	app_cmd = app_list[app_key]
	show_window_animated(app_cmd.app)
	if app_cmd.get("active_ui"):
		app_cmd.active_ui.grab_focus()
	if app_cmd.get("callback"):
		call(app_cmd.callback)


func _on_close_app_pressed(app_key: String) -> void:
	app_cmd = app_list[app_key]
	hide_window_animated(app_cmd.app)
	if app_cmd.get("close_callback"):
		call(app_cmd.close_callback)
	app_cmd.button.grab_focus()


func _on_power_button_pressed() -> void:
	SceneGameManager.change_scene("res://levels/cabam_level.tscn")

func clear_photos():
	for photo_row in photos.get_children():
		for photo in photo_row.get_children():
			photo.queue_free()

func delete_photo(slot: int):
	var dir = DirAccess.open(GameManager.photos_dir)
	var file_path = "%s.png" % [GameManager.photos[slot].get("filename")]
	if dir:
		if dir.file_exists(file_path):
			dir.remove(file_path)
	GameManager.photos.remove_at(slot)
	GameManager.photo_slot -= 1
	clear_photos()
	load_photo_data_silently()
	display_photos_with_animation()
	GameManager.check_all_goals(true)
	

func load_photos():
	var photo_rows = photos.get_children()
	var num_rows : int  = photo_rows.size()
	
	if not loading_files.is_visible():
		loading_files.popup()

	progress_bar.value = 0
	progress_bar.visible = true

	var photos_to_load = GameManager.photos

	if photos_to_load.is_empty() or num_rows == 0:
		if num_rows == 0 and not photos_to_load.is_empty():
			print("Erro: Fotos encontradas, mas 'photo_rows' está vazio.")
		
		progress_bar.max_value = 100
		var tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(progress_bar, "value", 100, 1.0)
		await tween.finished
		
	else:
		progress_bar.max_value = photos_to_load.size()
		@warning_ignore("integer_division")
		var photos_per_row = GameManager.photos_limit / num_rows 
		for i in photos_to_load.size():
			var filename = photos_to_load[i].get("filename")
			var file_path = "user://photos/%s.png" % (filename)

			if not FileAccess.file_exists(file_path):
				continue

			var image = Image.load_from_file(file_path)
			if image.is_empty():
				continue
			var texture = ImageTexture.create_from_image(image)
			var photo_display = photo_frame_button.instantiate()
			photo_display.texture = texture
			var button = photo_display.get_child(0) as TextureButton
			button.pressed.connect(delete_photo.bind(i))
			@warning_ignore("integer_division")
			var _index = i / photos_per_row
			var target_row = photo_rows[_index]
			target_row.add_child(photo_display)
			
			progress_bar.value = i + 1
			await get_tree().create_timer(0.1).timeout

	await get_tree().create_timer(0.5).timeout
	loading_files.hide()
	progress_bar.visible = false

func load_photo_data_silently():
	preloaded_photo_data.clear()
	var photos_to_load = GameManager.photos

	if photos_to_load.is_empty():
		return

	for i in photos_to_load.size():
		var photo_info = photos_to_load[i]
		var filename = photo_info.get("filename")
		var file_path = "user://photos/%s.png" % (filename)

		if not FileAccess.file_exists(file_path):
			continue

		var image = Image.load_from_file(file_path)
		if image.is_empty():
			continue
		
		preloaded_photo_data.append({
			"image": image,
			"game_manager_index": i
		})

func display_photos_with_animation():
	photo_rows = photos.get_children()
	var num_rows : int  = photo_rows.size()
	@warning_ignore("integer_division")
	var photos_per_row = GameManager.photos_limit / num_rows 
	
	if not loading_files.is_visible():
		loading_files.popup()

	progress_bar.value = 0
	progress_bar.visible = true

	if preloaded_photo_data.is_empty() or num_rows == 0:
		if num_rows == 0 and not preloaded_photo_data.is_empty():
			print("Erro: Fotos encontradas, mas 'photo_rows' está vazio.")
		
		progress_bar.max_value = 100
		var tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(progress_bar, "value", 100, 1.0)
		await tween.finished
		no_photo.show()
		
		
	else:
		progress_bar.max_value = preloaded_photo_data.size()
		
		for i in preloaded_photo_data.size():
			var data = preloaded_photo_data[i]
			
			var image: Image = data.get("image")
			var original_index: int = data.get("game_manager_index")

			var texture = ImageTexture.create_from_image(image)
			var photo_display = photo_frame_button.instantiate()
			
			photo_display.texture = texture
			var button = photo_display.get_child(0) as TextureButton
			
			button.pressed.connect(delete_photo.bind(original_index))
			
			@warning_ignore("integer_division")
			var _index = i / photos_per_row
			var target_row = photo_rows[_index]
			target_row.add_child(photo_display)
			
			progress_bar.value = i + 1
			await get_tree().create_timer(0.1).timeout

	await get_tree().create_timer(0.5).timeout
	loading_files.hide()
	progress_bar.visible = false
