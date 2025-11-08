extends RigidBody2D
@onready var area: Area2D = $Area
@export var speed: int = 150
@export var accuracy_score: int = 100
var result: Dictionary = {}
var direction: Vector2 = Vector2.RIGHT
var skill_check = false
var move: bool = false
var slot: int
@onready var timing_bar: HSlider = $TimingBar
@onready var collision: CollisionShape2D = $Collision
@onready var sprite: TextureRect = $Area/Sprite


func _ready() -> void:
	collision.disabled = true
	timing_bar.skill_check_completed.connect(save_photo)
	hide()


func _physics_process(delta: float) -> void:
	if !move:
		return
	
	var motion = direction * speed * delta
	var collistion = move_and_collide(motion)
	if collistion:
		direction *= -1


func start_framing(_direction: Vector2, _start_position: Vector2 = position ):
	
	for item: CollisionObject2D in area.get_overlapping_bodies():
		if item.collision_layer in [1,2]:
			return 
	if len(GameManager.photos) >= 4:
		return
	collision.disabled = false
	match _direction:
		Vector2.DOWN:
			rotation=deg_to_rad(180)
		Vector2.UP:
			rotation=deg_to_rad(0)
		Vector2.LEFT:
			rotation=deg_to_rad(-90)
		Vector2.RIGHT:
			rotation=deg_to_rad(90)
	position = _start_position
	show()
	slot = GameManager.photo_slot
	direction = _direction
	move = true


func take_picture():
	move = false
	collision.disabled = true
	timing_bar.show()
	timing_bar.start_skill_check()
	skill_check = true
	var items: Array = []
	var total = 0
	for item in area.get_overlapping_bodies():
		var points = GameManager.animals.get(item.name)
		items.append({"item_name":item.name,"points":points})
		total += points
	
	result["total"] = total
	result["items"] = items
	result["time"] = GameManager.get_time()
	screen_shot(slot)


func save_photo(focus_accuracy: float):
	timing_bar.hide()
	result["total"] *=  focus_accuracy / 100
	if len(GameManager.photos) < 4:
		GameManager.photos.append(result)
		GameManager.photo_slot = wrapi(slot + 1, 1, 5)
	hide()


func screen_shot(index:int):
	await get_tree().process_frame
	
	var full_image: Image = get_viewport().get_texture().get_image()
	
	if not full_image:
		return
	var capture_rect: Rect2 = sprite.get_global_rect()
	
	var cropped_image: Image = full_image.get_region(Rect2i(capture_rect))
	
	if not cropped_image or cropped_image.is_empty():
		return
	var file_path = "user://photo_%02d.png" % [index]
	var err = cropped_image.save_png(file_path)
	
	if err != OK:
		print("Erro ao salvar a foto PNG: ", err)
	else:
		print("Foto CORTADA (PNG) salva com sucesso em: ", file_path)
	
	
