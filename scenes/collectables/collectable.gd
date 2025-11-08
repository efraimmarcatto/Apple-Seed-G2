extends Area2D
class_name Collectable

@export var parent: CharacterBody2D
@export var collision_shape_2d: CollisionShape2D

@export_category("throw")
@export var throw_speed: float = 200.0
@export var throw_time: float = 0.25

enum STATES {DEFAULT,CARRIED,THROWN}

var state: STATES = STATES.DEFAULT
var throw_direction: Vector2 = Vector2.ZERO
var root_tree: Node2D

func _ready() -> void:
	add_to_group(Globals.GROUP_COLLECTABLE)
	if parent:
		root_tree = parent.get_parent()
	
func _physics_process(_delta: float) -> void:
	if state == STATES.THROWN and parent:
		parent.velocity = throw_direction * throw_speed
		parent.move_and_slide()

func is_carryble() -> bool:
	return state == STATES.DEFAULT

func is_carried() -> bool:
	return state == STATES.CARRIED

func carry(new_parent:Node2D, new_position:Vector2) -> void:
	state = STATES.CARRIED
	if collision_shape_2d:
		collision_shape_2d.disabled = true
	if parent:
		set_carry_position(new_position)
		#parent.z_index = 1
		parent.reparent(new_parent,true)

func set_carry_position(new_position:Vector2) -> void:
	if parent:
		parent.global_position = new_position

func throw(direction: Vector2 = Vector2.RIGHT) -> void:
	state = STATES.THROWN
	throw_direction = direction
	if parent:
		await get_tree().create_timer(0.05).timeout
		parent.reparent(root_tree,true)
	if collision_shape_2d:
		collision_shape_2d.disabled = false
		
	await get_tree().create_timer(throw_time).timeout
	state = STATES.DEFAULT
