extends Area2D

@export var target: CharacterBody2D
@export var walk_behavior: WalkBehavior
@export var eat_collectable_controller: Area2D
@export var apple_emoji: Sprite2D

@export var smoke_effect:PackedScene
@export var audio_angry: AudioStreamPlayer

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
	if audio_angry:
		audio_angry.play()
		
	await get_tree().create_timer(0.5).timeout
	if apple_emoji:
		apple_emoji.visible = false
	
	if smoke_effect and target:
		var instance_smoke_effect = smoke_effect.instantiate()
		instance_smoke_effect.global_position = target.global_position
		target.get_parent().add_child(instance_smoke_effect)
	
	target.call_deferred("queue_free")

func _on_body_entered(body: Node) -> void:
	if enabled and (body.is_in_group("Stone") or body.is_in_group("Player")):
		if body.is_in_group("Stone"):
			var collectable:Collectable = ComponentHelper.get_first_of_type_by_classname(body, Collectable)
			if not collectable or collectable.state != collectable.STATES.THROWN:
				return
				
		if eat_collectable_controller and eat_collectable_controller.state == eat_collectable_controller.STATES.DEFAULT:
			run()

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
