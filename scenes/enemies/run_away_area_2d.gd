extends Area2D
class_name RunAwayController

@export var target: CharacterBody2D
@export var walk_behavior: WalkBehavior
@export var eat_collectable_controller: Area2D
@export var apple_emoji: Sprite2D

@export var smoke_effect:PackedScene
@export var audio_angry: AudioStreamPlayer

enum STATES {DEFAULT, EMOJI, RUN}

var state: STATES = STATES.DEFAULT

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
	
	state = STATES.EMOJI
	
	await get_tree().create_timer(1, false).timeout
	if apple_emoji:
		apple_emoji.visible = false
	
	if smoke_effect and target:
		var instance_smoke_effect = smoke_effect.instantiate()
		target.get_parent().add_child(instance_smoke_effect)
		instance_smoke_effect.global_position = target.global_position
	
	state = STATES.RUN
	
	target.call_deferred("queue_free")

func _on_body_entered(body: Node) -> void:
	if enabled and (body.is_in_group("Stone") or body.is_in_group("Player") or (not eat_collectable_controller and body.is_in_group("Food"))):
		
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
		
		if body.is_in_group("Stone"):
			var collectable:Collectable = ComponentHelper.get_first_of_type_by_classname(body, Collectable)
			if not collectable or collectable.state != collectable.STATES.THROWN:
				return
		if eat_collectable_controller and eat_collectable_controller.state == eat_collectable_controller.STATES.DEFAULT:
			run()
		elif not eat_collectable_controller:
			run()

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
