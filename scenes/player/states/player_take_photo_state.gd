extends State

@export var player: Player
@export var character_movement_controller: CharacterMovementController
@export var photograph: Photograph
@export var animation_tree: AnimationTree
@export var emoji_sprite: Sprite2D

enum STATES {DEFAULT, START, PHOTO, SKILL_CHECK, EXIT, COLDOWN}
var state: STATES = STATES.DEFAULT

# nome do state
func get_state_name() -> String:
	return "take_photo"

func _ready() -> void:
	if emoji_sprite:
		emoji_sprite.visible = false
		
	if photograph:
		photograph.photo_finish.connect(on_state_exit)

# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

func _on_state_process(_delta : float) -> void:
	if photograph:
		if state == STATES.PHOTO and Input.is_action_just_pressed("take_picture"):
			state = STATES.SKILL_CHECK
			photograph.take_picture()

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(delta : float) -> void:
	if player and character_movement_controller:
		character_movement_controller.horizontal_movement(player, delta, 0)
		character_movement_controller.vertical_movement(player, delta, 0)
		character_movement_controller.move_and_slide(player)
	
# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	state = STATES.START
	var emoji_frame = 3
	if len(GameManager.photos) >= GameManager.photos_limit:
		emoji_frame = 4
		
	if emoji_sprite:
		emoji_sprite.visible = true
		emoji_sprite.frame = emoji_frame
	
	if animation_tree:
		if character_movement_controller:
			animation_tree.set("parameters/idle/BlendSpace2D/blend_position", character_movement_controller.last_movement_direction.normalized())
		animation_tree["parameters/playback"].travel("idle")
	
	if photograph and len(GameManager.photos) < GameManager.photos_limit:
		await get_tree().create_timer(0.2).timeout
		photograph.start_framing(character_movement_controller.last_movement_direction, global_position)
		state = STATES.PHOTO
	else:
		await get_tree().create_timer(1).timeout
		state = STATES.EXIT
		on_state_exit()
		
# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	if emoji_sprite:
		emoji_sprite.visible = false

# Função que define as condições para transições entre estados
func _on_state_check_transitions(_current_state_name:String, _current_state:Node) -> void:
	if _current_state_name != get_state_name():
		if able_to_take_photo():
			transition_to(get_state_name())

func able_to_take_photo() -> bool:
	return state == STATES.DEFAULT and Input.is_action_just_pressed("take_picture") and player and  player.carry_controller and not player.carry_controller.is_carrying()

func on_state_exit() -> void:
	state = STATES.COLDOWN
	transition_to("idle")
	await get_tree().create_timer(0.2).timeout
	state = STATES.DEFAULT
