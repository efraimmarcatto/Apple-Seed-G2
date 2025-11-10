extends State

@export var character: CharacterBody2D
@export var character_movement_controller: CharacterMovementController
@export var animation_player: AnimationPlayer

@export_category("Animations")
@export var animation_name_up:String = "walk_up"
@export var animation_name_down:String = "walk_down"
@export var animation_name_left:String = "walk_left"
@export var animation_name_right:String = "walk_right"

# nome do state
func get_state_name() -> String:
	return "walk"
	
# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(delta : float) -> void:
	if character and character_movement_controller:
		character_movement_controller.horizontal_movement(character, delta)
		character_movement_controller.vertical_movement(character, delta)
		character_movement_controller.move_and_slide(character)
	
	animation()
	
	# Função que define as condições para transições entre estados
func _on_state_next_transitions() -> void:
	if character_movement_controller:
		if not character_movement_controller.is_able_to_walk():
			transition_to("idle")
	
# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	animation()
	
# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	pass


func animation() -> void:
	if character_movement_controller:
		if character_movement_controller.movement_direction.y > 0:
			if animation_player and animation_player.has_animation(animation_name_down):
				animation_player.play(animation_name_down)
		elif character_movement_controller.movement_direction.y < 0:
			if animation_player and animation_player.has_animation(animation_name_up):
				animation_player.play(animation_name_up)
		elif character_movement_controller.movement_direction.x < 0.2:
			if animation_player.has_animation(animation_name_left):
				animation_player.play(animation_name_left)
		elif character_movement_controller.movement_direction.x > 0:
			if animation_player.has_animation(animation_name_right):
				animation_player.play(animation_name_right)
	
