extends Node2D
class_name PhotoStatus

@export var target_name:String
@export var sprite:Sprite2D
@export var character_movement_controller: CharacterMovementController
@export var state_machine: StateMachine
@export var eat_collectable_controller: EatCollectableControler
@export var run_away_area_2d: RunAwayController


var direction: Vector2
var state_name: String
var is_emoji_apple: bool
var is_eating: bool
var is_emoji_angry: bool
var is_runing: bool
var is_facing_down: bool

func _ready() -> void:
	if not target_name:
		target_name = get_parent().name

func _process(_delta: float) -> void:
	if state_machine:
		state_name = state_machine.current_state_name
	
	if character_movement_controller:
		direction = character_movement_controller.last_movement_direction
		if direction.y == 1:
			is_facing_down = true
		else:
			is_facing_down = false
		
		
	if eat_collectable_controller and eat_collectable_controller.state == eat_collectable_controller.STATES.EMOJI:
		is_emoji_apple = true
	else:
		is_emoji_apple = false
	
	if eat_collectable_controller and eat_collectable_controller.state == eat_collectable_controller.STATES.EAT:
		is_eating = true
	else:
		is_eating = false

	if run_away_area_2d and run_away_area_2d.state == run_away_area_2d.STATES.EMOJI:
		is_emoji_angry = true
	else:
		is_emoji_angry = false
		
	if (run_away_area_2d and run_away_area_2d.state == run_away_area_2d.STATES.RUN) or (eat_collectable_controller and eat_collectable_controller.state == eat_collectable_controller.STATES.RUN):
		is_runing = true
	else:
		is_runing = false

func check_sprite_in_collision_area(area_shape: CollisionShape2D) -> String:
	# Garantir que ambos existem
	if sprite or not is_instance_valid(sprite):
		return "outside"
	if area_shape == null or not is_instance_valid(area_shape):
		return "outside"

	# Garantir que o shape é retangular
	if not area_shape.shape is RectangleShape2D:
		push_error("check_sprite_in_collision_area: area_shape precisa ser RectangleShape2D")
		return "outside"

	# === SPRITE → PEGAR OS 4 VÉRTICES EM GLOBAL ===
	var rect := sprite.get_rect() # tamanho local
	var tf := sprite.get_global_transform()

	var verts = [
		tf * rect.position,
		tf * (rect.position + Vector2(rect.size.x, 0)),
		tf * (rect.position + Vector2(0, rect.size.y)),
		tf * (rect.position + rect.size)
	]

	# === ÁREA → RECT GLOBAL ===
	var area_rect_size = area_shape.shape.size
	var area_global_pos = area_shape.global_position
	var area_global_rot = area_shape.global_rotation

	# matriz de transformação global da área
	var area_tf = Transform2D(area_global_rot, area_global_pos)
	var half = area_rect_size * 0.5

	var area_verts = [
		area_tf * Vector2(-half.x, -half.y),
		area_tf * Vector2( half.x, -half.y),
		area_tf * Vector2(-half.x,  half.y),
		area_tf * Vector2( half.x,  half.y)
	]

	# Criar bounding box global da área
	var min_ax = min(area_verts[0].x, area_verts[1].x, area_verts[2].x, area_verts[3].x)
	var max_ax = max(area_verts[0].x, area_verts[1].x, area_verts[2].x, area_verts[3].x)
	var min_ay = min(area_verts[0].y, area_verts[1].y, area_verts[2].y, area_verts[3].y)
	var max_ay = max(area_verts[0].y, area_verts[1].y, area_verts[2].y, area_verts[3].y)

	var area_rect = Rect2(
		Vector2(min_ax, min_ay),
		Vector2(max_ax - min_ax, max_ay - min_ay)
	)

	# === VERIFICAÇÃO ===
	var points_inside = 0

	for p in verts:
		if area_rect.has_point(p):
			points_inside += 1

	if points_inside == 4:
		return "inside"
	elif points_inside > 0:
		return "partial"
	else:
		return "outside"
