extends State

@export var character: CharacterBody2D
@export var character_movement_controller: CharacterMovementController
@export var animation_player: AnimationPlayer

@export_category("Animations")
@export var animation_name_up:String = "idle_up"
@export var animation_name_down:String = "idle_down"

# nome do state
func get_state_name() -> String:
	return "idle"
	
# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(delta : float) -> void:
	if character and character_movement_controller:
		character_movement_controller.horizontal_movement(character, delta, 0)
		character_movement_controller.vertical_movement(character, delta, 0)
		character_movement_controller.move_and_slide(character)

# Função que define as condições para transições entre estados
func _on_state_next_transitions() -> void:
	if character_movement_controller:
		if character_movement_controller.is_able_to_walk():
			transition_to("walk")

# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	if character_movement_controller and animation_player:
		if character_movement_controller.last_movement_direction.y > 0:
			if animation_player.has_animation(animation_name_down):
				animation_player.play(animation_name_down)
		elif character_movement_controller.last_movement_direction.y < 0:
			if animation_player.has_animation(animation_name_up):
				animation_player.play(animation_name_up)
	
# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	pass
