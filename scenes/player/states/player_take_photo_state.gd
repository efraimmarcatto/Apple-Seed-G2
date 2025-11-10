extends State

@export var player: Player
@export var character_movement_controller: CharacterMovementController
@export var photograph: Photograph

# nome do state
func get_state_name() -> String:
	return "take_photo"
	
# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

func _on_state_process(_delta : float) -> void:
	if photograph:
		if Input.is_action_just_released("take_picture"):
			photograph.take_picture()
			
		if not photograph.enabled:
			on_state_exit()

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(delta : float) -> void:
	if player and character_movement_controller:
		character_movement_controller.horizontal_movement(player, delta, 0)
		character_movement_controller.vertical_movement(player, delta, 0)
		character_movement_controller.move_and_slide(player)
	
# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	if photograph:
		photograph.start_framing(character_movement_controller.last_movement_direction, global_position)
	
	
# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	pass

# Função que define as condições para transições entre estados
func _on_state_check_transitions(_current_state_name:String, _current_state:Node) -> void:
	if _current_state_name != get_state_name():
		if able_to_take_photo():
			transition_to(get_state_name())

func able_to_take_photo() -> bool:
	return Input.is_action_just_pressed("take_picture") and  player.carry_controller and not player.carry_controller.is_carrying()

func on_state_exit() -> void:
	transition_to("idle")
