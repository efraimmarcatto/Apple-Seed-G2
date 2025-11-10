extends Area2D

@export var target: CharacterBody2D
@export var walk_behavior: WalkBehavior
@export var eat_collectable_controller: Area2D
@export var apple_emoji: Sprite2D

var enabled: bool = true

func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	body_entered.connect(_on_body_entered)
	if apple_emoji:
		apple_emoji.visible = false

func run() -> void:
	if walk_behavior:
		walk_behavior.disable()
	if apple_emoji:
		apple_emoji.frame = 1
		apple_emoji.visible = true
		
	await get_tree().create_timer(1).timeout
	if apple_emoji:
		apple_emoji.visible = false
	target.call_deferred("queue_free")

func _on_body_entered(body: Node) -> void:
	if enabled and (body.is_in_group("Stone") or body.is_in_group("Player")):
		if eat_collectable_controller and eat_collectable_controller.state == eat_collectable_controller.STATES.DEFAULT:
			run()

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
