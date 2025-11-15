extends RigidBody2D
class_name Photograph

@onready var area: Area2D = $Area
@export var speed: int = 100
@export var accuracy_score: int = 100
@onready var timing_bar: Control = %TimingBar
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: Sprite2D = $Area/Sprite
@onready var mask: ColorRect = $MaskLayer/Mask
@onready var photo_click: AudioStreamPlayer2D = $PhotoClick
@onready var flash: ColorRect = $MaskLayer/Flash

var capture_rect: Rect2 
var result: Dictionary = {}
var direction: Vector2 = Vector2.RIGHT
var skill_check = false
var move: bool = false
var slot: int

signal photo_finish

func _ready() -> void:
	collision.disabled = true
	hide()

func _physics_process(_delta: float) -> void:
	if !move:
		linear_velocity = Vector2.ZERO 
		return
	linear_velocity = direction * speed
	
	var sprite_local_rect = sprite.get_rect()
	var sprite_global_transform = sprite.get_global_transform()
	var world_rect = sprite_global_transform * sprite_local_rect
	var canvas_transform = get_viewport().get_canvas_transform()
	capture_rect = canvas_transform * world_rect
	var rect_vec4 = Vector4(capture_rect.position.x,capture_rect.position.y, capture_rect.size.x, capture_rect.size.y)
	mask.material.set_shader_parameter("hole_rect", rect_vec4)

func start_framing(_direction: Vector2, _start_position: Vector2 = position ):
	if len(GameManager.photos) >= GameManager.photos_limit:
		return
	match _direction:
		Vector2.DOWN:
			rotation = deg_to_rad(180)
		Vector2.UP:
			rotation = deg_to_rad(0)
		Vector2.LEFT:
			rotation = deg_to_rad(-90)
		Vector2.RIGHT:
			rotation = deg_to_rad(90)

	move = true
	global_position = _start_position
	show()
	slot = GameManager.photo_slot
	direction = _direction
	move = true
	mask.visible = true


func take_picture():
	if !move and !skill_check:
		return
	move = false
	mask.visible = false
	collision.disabled = true
	timing_bar.show()
	timing_bar.start_skill_check()
	skill_check = true
	var items: Array = []
	var total = 0
	for body in area.get_overlapping_bodies():

		var status = ComponentHelper.get_first_of_type_by_classname(body, PhotoStatus)
		if status:
			items.append({
			"name":status.state_name,
			"is_emoji_apple":status.is_emoji_apple,
			"is_eating":status.is_eating,
			"is_emoji_angry":status.is_emoji_angry,
			"is_runing":status.is_runing,
			"is_facing_down":status.is_facing_down,
			})
	result["items"]= items if items else []
	var filename = await screen_shot()
	result["filename"] = filename
		
	get_tree().paused = true


func save_photo(focus_accuracy: float):
	timing_bar.hide()
	if "total" in result:
		result["total"] *=  focus_accuracy / 100
	if GameManager.photos.size() <= GameManager.photos_limit:
		GameManager.photos.append(result)
		GameManager.photo_count_updated.emit(slot)
		GameManager.photo_slot = wrapi(slot + 1, 1, GameManager.photos_limit + 1)
		result = {}
	hide()
	photo_click.play()
	camera_flash()
	photo_finish.emit()
	get_tree().paused = false
	
func screen_shot() -> String:
	sprite.hide()
	await get_tree().process_frame

	var full_image: Image = get_viewport().get_texture().get_image()

	if not full_image:
		return ""

	var cropped_image: Image = full_image.get_region(Rect2i(capture_rect))

	if not cropped_image or cropped_image.is_empty():
		return ""
	var filename = str(Time.get_unix_time_from_system()).replace(".","")
	var file_path = GameManager.photos_dir + "/%s.png" % [filename]
	if cropped_image.get_size().y > cropped_image.get_size().x:
		cropped_image.rotate_90(CLOCKWISE)
	var err = cropped_image.save_png(file_path)

	if err != OK:
		print("Erro ao salvar a foto PNG: ", err)

	sprite.show()
	return filename

func cancel_photo():
	move = false
	linear_velocity = Vector2.ZERO
	hide()
	mask.visible = false
	
	timing_bar.cancel_check() 
	skill_check = false
	result = {}
	photo_finish.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if move:
		cancel_photo()


func camera_flash(duration: float = .8):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(flash, "modulate:a", 1.0, duration / 2.0)
	tween.tween_property(flash, "modulate:a", 0.0, duration / 2.0)
	
	await tween.finished
