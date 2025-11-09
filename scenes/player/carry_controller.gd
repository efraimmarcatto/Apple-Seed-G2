extends Area2D
class_name CarryController

@export var carry_marker_2d: Marker2D
@export var player: Player
@export var character_movement_controller: CharacterMovementController
@export var carry_arrow:Sprite2D


var carrying_collectable: Collectable = null ## item carregado
var near_collectable: Collectable = null ## coletavel em frente

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if carry_arrow:
		carry_arrow.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('key_action'):
		pick_collectable()
	if Input.is_action_just_released('key_action'):
		throw_collectable()
		
	if carrying_collectable and is_instance_valid(carrying_collectable) and carrying_collectable.has_method("set_carry_position"):
		carrying_collectable.set_carry_position(carry_marker_2d.global_position)

func is_carrying() -> bool:
	return (carrying_collectable and is_instance_valid(carrying_collectable) and carrying_collectable.has_method("is_carried") and carrying_collectable.is_carried()) or Input.is_action_pressed("key_action")

func pick_collectable() -> void:
	if near_collectable and is_instance_valid(near_collectable) and near_collectable.has_method("is_carryble") and near_collectable.is_carryble():
		carrying_collectable = near_collectable
		near_collectable = null
		carrying_collectable.carry(player, carry_marker_2d.global_position)
		
		if carry_arrow:
			await get_tree().create_timer(0.1).timeout
			carry_arrow.visible = true
		
func throw_collectable() -> void:
	if carrying_collectable and is_instance_valid(carrying_collectable):
		if character_movement_controller:
			carrying_collectable.throw(character_movement_controller.last_movement_direction)
	carrying_collectable = null
	
	if carry_arrow:
		carry_arrow.visible = false
	
	# remove a colisão do player com o item temporariamente
	if player:
		player.set_collision_mask_value(5, false)
		await get_tree().create_timer(0.1).timeout
		player.set_collision_mask_value(5, true)
	

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group(Globals.GROUP_COLLECTABLE) and area.has_method("is_carryble") and area.is_carryble():
		near_collectable = area

func _on_area_exited(area:Area2D) -> void:
	if area.is_in_group(Globals.GROUP_COLLECTABLE):
		if area == near_collectable:
			near_collectable = null
