extends Control

@onready var time: Label = $Desktop/Layout/Time
@onready var photo_app: Panel = $PhotoApp
@onready var mail_app: Panel = $MailApp
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var photo_button: TextureButton = $Desktop/Layout/MarginContainer/Menu/Bar/PhotoButton
@onready var mail_button: TextureButton = $Desktop/Layout/MarginContainer/Menu/Bar/MailButton
@onready var mail_scroll_container: ScrollContainer = $MailApp/Window/Layout/MarginContainer2/MailScrollContainer
@onready var photos: VBoxContainer = $PhotoApp/Window/Photos
@onready var loading_files: PopupPanel = $PhotoApp/LoadingFiles
@onready var app_list: Dictionary= {
	"photoapp":{"app":photo_app, "button":photo_button, "active_ui":null, "callback":"load_pictures", "close_callback":"clear_photos"}, 
	"mailapp":{"app":mail_app, "button":mail_button, "active_ui":mail_scroll_container, "callback":"", "close_callback":""}
	}
var app_cmd:  Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_window(photo_app)
	setup_window(mail_app)
	photo_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	GameManager.change_scene("res://levels/game.tscn")

func clear_photos():
	for photo_row in photos.get_children():
		for photo in photo_row.get_children():
			photo.queue_free()

func load_pictures():
	var photo_rows = photos.get_children()
	loading_files.popup()
	var photo_paths: Array[String] = []
	var photo_dir = "user://photos/"
	
	var dir = DirAccess.open(photo_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				photo_paths.append(photo_dir.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Erro: Não foi possível abrir o diretório ", photo_dir)
		return

	if photo_paths.is_empty():
		print("Nenhuma foto encontrada.")
		return

	progress_bar.max_value = photo_paths.size()
	progress_bar.value = 0
	progress_bar.visible = true

	for i in photo_paths.size():
		var file_path = photo_paths[i]

		var image = Image.load_from_file(file_path)
		if image.is_empty():
			continue
		var texture = ImageTexture.create_from_image(image)

		var photo_display = TextureRect.new()
		photo_display.texture = texture
		var texture_size = photo_display.texture.get_size()
		photo_display.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		photo_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if texture_size.y > texture_size.x:
			photo_display.rotation_degrees = 90
		
		photo_rows[i%photos.get_child_count()].add_child(photo_display)
		progress_bar.value = i + 1
		await get_tree().create_timer(0.1).timeout

	await get_tree().create_timer(0.5).timeout
	loading_files.hide()
	progress_bar.visible = false
