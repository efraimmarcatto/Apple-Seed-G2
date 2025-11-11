extends State

@export var player: Player
@export var character_movement_controller: CharacterMovementController
@export var animation_tree: AnimationTree
@export var emoji_sprite: Sprite2D

# nome do state
func get_state_name() -> String:
	return "eat"

func _ready() -> void:
	if emoji_sprite:
		emoji_sprite.visible = false

# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

func _on_state_process(_delta : float) -> void:
	pass

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(delta : float) -> void:
	if player and character_movement_controller:
		character_movement_controller.horizontal_movement(player, delta, 0)
		character_movement_controller.vertical_movement(player, delta, 0)
		character_movement_controller.move_and_slide(player)
	
# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	if emoji_sprite:
		emoji_sprite.visible = true
		emoji_sprite.frame = 2
		
	if player and player.carry_controller:
		player.carry_controller.eat_collectable()
		
	if animation_tree:
		if character_movement_controller:
			animation_tree.set("parameters/idle/BlendSpace2D/blend_position", character_movement_controller.last_movement_direction.normalized())
		animation_tree["parameters/playback"].travel("eat")
		
	await get_tree().create_timer(1.5).timeout
	transition_to("idle")
	
	
	
# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	if emoji_sprite:
		emoji_sprite.visible = false

# Função que define as condições para transições entre estados
func _on_state_check_transitions(_current_state_name:String, _current_state:Node) -> void:
	if _current_state_name != get_state_name():
		if able_to_eat():
			transition_to(get_state_name())

func able_to_eat() -> bool:
	return Input.is_action_just_pressed("take_picture") and  player.carry_controller and player.carry_controller.is_carrying_food()
