extends CharacterBody2D
class_name Player

@export var character_movement_controller: CharacterMovementController

var carrying_item: Collectable = null ## item carregado

func _ready() -> void:
	add_to_group(Globals.GROUP_PLAYER)
	if character_movement_controller:
		character_movement_controller.setup(self)

func _process(_delta: float) -> void:
	manage_inputs()
	
func manage_inputs() -> void:
	# controla os inputs
	if character_movement_controller:
		var input_axis = Input.get_vector("key_left", "key_right", "key_up", "key_down")
		character_movement_controller.set_movement_direction(input_axis)

func is_carrying() -> bool:
	#return carrying_item and is_instance_valid(carrying_item)
	return Input.is_action_pressed("key_action")
