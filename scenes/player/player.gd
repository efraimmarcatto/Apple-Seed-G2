extends CharacterBody2D
class_name Player

@export var character_movement_controller: CharacterMovementController
@export var carry_controller: CarryController


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
