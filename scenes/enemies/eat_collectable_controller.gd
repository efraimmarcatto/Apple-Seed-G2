extends Area2D

@export var target: CharacterBody2D
@export var character_movement_controller: CharacterMovementController
@export var walk_behavior: WalkBehavior

@export_category("follow")
@export var stop_distance: float = 15         # Distância mínima para parar

var food: Apple


enum STATES {DEFAULT,FOLLOW,EAT}
var state: STATES = STATES.DEFAULT

func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	body_entered.connect(_on_body_entered)

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
		food.be_bitten(run)

func run() -> void:
	if target:
		await get_tree().create_timer(0.5).timeout
		target.call_deferred("queue_free")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Food") and body is Apple:
		food = body
		state = STATES.FOLLOW
		if walk_behavior:
			walk_behavior.disable()
