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
	if Input.is_action_just_pressed("take_picture"):
		$Photograph.start_framing(character_movement_controller.last_movement_direction, global_position)
	if Input.is_action_just_released("take_picture"):
		$Photograph.take_picture()
	
func manage_inputs() -> void:
	# controla os inputs
	if character_movement_controller:
		var input_axis = Input.get_vector("key_left", "key_right", "key_up", "key_down")
		character_movement_controller.set_movement_direction(input_axis)
