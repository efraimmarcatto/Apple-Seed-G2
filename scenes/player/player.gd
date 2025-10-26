extends CharacterBody2D
@onready var animation: AnimationPlayer = $Animation
var attacking:= false

const SPEED = 150
@onready var sprite: Sprite2D = $Sprite
var last_direction: Vector2 = Vector2.DOWN


func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_accept"):
		attacking = true
		if last_direction == Vector2.DOWN:
			animation.play("attack_down")
		elif last_direction == Vector2.UP:
			animation.play("attack_up")
		elif last_direction == Vector2.LEFT:
			animation.play("attack_side")
			sprite.flip_h = true
		elif last_direction == Vector2.RIGHT:
			animation.play("attack_side")
			sprite.flip_h = false
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	if attacking:
		return 
	if velocity == Vector2.ZERO:
		if last_direction == Vector2.DOWN:
			animation.play("idle_down")
		elif last_direction == Vector2.UP:
			animation.play("idle_up")
		elif last_direction == Vector2.LEFT:
			animation.play("idle_side")
			sprite.flip_h = true
		elif last_direction == Vector2.RIGHT:
			animation.play("idle_side")
			sprite.flip_h = false
	else:
		if velocity.x == 0:
			if velocity.y < 0:
				last_direction = Vector2.UP
				animation.play("walk_up")
			elif velocity.y > 0:
				last_direction = Vector2.DOWN
				animation.play("walk_down")
		else:
			if velocity.x > 0:
				sprite.flip_h = false
				last_direction = Vector2.RIGHT
			if velocity.x < 0:
				last_direction = Vector2.LEFT
				sprite.flip_h = true
			animation.play("walk_side")


	move_and_slide()


func _on_animation_animation_finished(anim_name: StringName) -> void:
	if "attack" in anim_name:
		attacking = false
