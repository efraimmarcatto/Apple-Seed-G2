extends Area2D

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


var enabled: bool = true
var food: Apple

enum STATES {DEFAULT,EMOJI,FOLLOW,EAT}
var state: STATES = STATES.DEFAULT

func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	body_entered.connect(_on_body_entered)
	if apple_emoji:
		apple_emoji.visible = false

func able_to_eat() -> bool:
	return false

func _physics_process(_delta: float) -> void:
	follow_food()

func follow_food() -> void:
	if not target or not food or state != STATES.FOLLOW:
		return

	var direction = (food.global_position - target.global_position)
	var distance = direction.length()
	# Se já está perto o suficiente, para
	if distance <= stop_distance:
		bite_food()
		return

	# Normaliza e aplica velocidade
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
	if enabled and body.is_in_group("Food") and body is Apple and state == STATES.DEFAULT:
		food = body
		food.was_eaten.connect(run)
		show_emoji()
		if walk_behavior:
			walk_behavior.disable()

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
