extends State

@export var player: Player
@export var character_movement_controller: CharacterMovementController
@export var animation_tree: AnimationTree

# nome do state
func get_state_name() -> String:
	return "walk"
	
# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(delta : float) -> void:
	if player and character_movement_controller:
		character_movement_controller.horizontal_movement(player, delta)
		character_movement_controller.vertical_movement(player, delta)
		character_movement_controller.move_and_slide(player)
		
		if animation_tree and character_movement_controller.movement_direction != Vector2.ZERO:
			animation_tree.set("parameters/walk/BlendSpace2D/blend_position", character_movement_controller.movement_direction.normalized())
	
	# Função que define as condições para transições entre estados
func _on_state_next_transitions() -> void:
	if player and character_movement_controller:
		if player.is_carrying() and character_movement_controller.is_able_to_walk():
			transition_to("carry_walk")
		elif not character_movement_controller.is_able_to_walk():
			transition_to("idle")
	
# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	if animation_tree:
		animation_tree["parameters/playback"].travel("walk")
	
# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	pass
