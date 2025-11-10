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
		var input_y = Input.get_axis( "key_up", "key_down")
		var input_x = Input.get_axis("key_left", "key_right")
		var input_axis = Vector2(input_x, input_y)
		character_movement_controller.set_movement_direction(input_axis)
