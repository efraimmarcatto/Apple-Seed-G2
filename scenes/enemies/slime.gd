extends CharacterBody2D


const SPEED = 80

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var target = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(target.global_position)
	
	velocity = direction * SPEED
	if velocity.x <= 0:
		sprite.flip_h = true
	else :
		sprite.flip_h = false

	move_and_slide()
