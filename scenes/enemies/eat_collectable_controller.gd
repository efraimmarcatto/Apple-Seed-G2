extends Area2D
class_name EatCollectableControler

@export var target: CharacterBody2D
@export var character_movement_controller: CharacterMovementController
@export var walk_behavior: WalkBehavior
@export var smoke_effect:PackedScene
@export var audio_see_food: AudioStreamPlayer
@export var audio_eat_food: AudioStreamPlayer

@export_category("follow")
@export var delay_emoji: float = 1
@export var apple_emoji: Sprite2D
@export var stop_distance: float = 15 # Distância mínima para parar

@export var navigation_agent: NavigationAgent2D 

var enabled: bool = true
var food: Apple
var collectable:Collectable

enum STATES {DEFAULT,EMOJI,FOLLOW,FOLLOW_PLAYER,EAT,RUN}
var state: STATES = STATES.DEFAULT

func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	body_entered.connect(_on_body_entered)
	if apple_emoji:
		apple_emoji.visible = false
		
	if navigation_agent:
		# Impede que o NavigationAgent tente mover fisicamente o personagem
		navigation_agent.avoidance_enabled = false
		navigation_agent.velocity = Vector2.ZERO

func able_to_eat() -> bool:
	return false

func _physics_process(_delta: float) -> void:
	follow_food()

func follow_food() -> void:
	if not target or not food or state != STATES.FOLLOW:
		return
	if is_instance_valid(food):
		
		if state != STATES.FOLLOW_PLAYER and collectable and collectable.state == collectable.STATES.CARRIED:
			state = STATES.FOLLOW_PLAYER
			run()
			# caso for querer que ele siga o player
			
			
		
		if not navigation_agent:
			return follow_food_simple()  # fallback
		
		# Destino da maçã dentro do NavigationAgent
		navigation_agent.target_position = food.global_position

		# Pega direção do caminho NavMesh
		var next_path_point = navigation_agent.get_next_path_position()
		var direction = (next_path_point - target.global_position)
		var distance = direction.length()
		
		# Se já está perto da comida, morde
		if distance <= stop_distance:
			bite_food()
			return

		# Normaliza direção
		direction = direction.normalized()
		# Move usando seu controlador original
		if character_movement_controller and character_movement_controller.has_method("set_movement_direction"):
			character_movement_controller.set_movement_direction(direction)


# Método antigo, caso não exista NavigationAgent
func follow_food_simple() -> void:
	if not target or not food:
		return
	var direction = (food.global_position - target.global_position)
	var distance = direction.length()

	if distance <= stop_distance:
		bite_food()
		return

	direction = direction.normalized()
	if character_movement_controller and character_movement_controller.has_method("set_movement_direction"):
		character_movement_controller.set_movement_direction(direction)

func bite_food() -> void:
	if  food and state == STATES.FOLLOW:
		state = STATES.EAT
		food.be_bitten()
	if audio_eat_food:
		audio_eat_food.play()

func run() -> void:
	await get_tree().create_timer(0.5).timeout
		
	if smoke_effect and target:
		var instance_smoke_effect = smoke_effect.instantiate()
		instance_smoke_effect.global_position = target.global_position
		target.get_parent().add_child(instance_smoke_effect)
	if target:
		target.call_deferred("queue_free")
		

func show_emoji() -> void:
	state = STATES.RUN
	if audio_see_food:
		audio_see_food.play()
	
	state = STATES.EMOJI
	if apple_emoji:
		apple_emoji.frame = 0
		apple_emoji.visible = true
	await get_tree().create_timer(delay_emoji).timeout
	state = STATES.FOLLOW
	if apple_emoji:
		apple_emoji.visible = false
	
func _on_body_entered(body: Node) -> void:
	if not enabled:
		return
	
	if not (body.is_in_group("Food") and body is Apple):
		return
	
	if state != STATES.DEFAULT:
		return
	
	if navigation_agent:
		navigation_agent.target_position = body.global_position

		# Aguarda um frame para o agente atualizar o caminho
		await get_tree().process_frame

		if not navigation_agent.is_target_reachable():
			#print("Sem caminho até a comida!")
			return
	
		var from = target.global_position
		var to = body.global_position
		
		var space_state := target.get_world_2d().direct_space_state
		
		# O ray usa exatamente o mesmo collision_mask do target
		var params := PhysicsRayQueryParameters2D.new()
		params.from = from
		params.to = to
		params.exclude = [target]               # ignora o player
		params.collision_mask = target.collision_mask
		
		var result := space_state.intersect_ray(params)
		
		# Se bateu em algo e não é a própria comida → OBSTÁCULO, ignora
		if result and result.collider != body:
			# DEBUG opcional
			#print("Obstáculo detectado entre player e comida:", result.collider)
			return
		
	collectable = ComponentHelper.get_first_of_type_by_classname(body, Collectable)
	
	food = body
	food.was_eaten.connect(run)
	show_emoji()
	if walk_behavior:
		walk_behavior.disable()

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
