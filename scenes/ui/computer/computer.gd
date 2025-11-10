extends Control

@onready var time: Label = $Desktop/Layout/Time
@onready var close_button: TextureButton = $PhotoApp/MarginContainer/CloseButton
@onready var photo_app: Panel = $PhotoApp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_window(photo_app)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_time()


func update_time():
	var now = Time.get_datetime_dict_from_system()
	time.text = "%02d:%02d" % [now.hour, now.minute]

func setup_window(window: Control):
	window.hide()
	window.modulate.a = 0.0 # Totalmente transparente
	window.scale = Vector2(0.8, 0.8) # Um pouco menor para o "pop"
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

func _on_photo_pressed() -> void:
	show_window_animated(photo_app)


func _on_close_button_pressed() -> void:
	hide_window_animated(photo_app)
