extends Node
class_name CharacterMovementController

@export_category("Movement")
@export var speed: float = 80.0 ## Velocidade máxima de movimento do personagem (em pixels por segundo).
@export var acceleration: float = 400.0 ## Aceleração ao mover-se na mesma direção (em pixels por segundo ao quadrado).
@export var deceleration: float = 500.0 ## Desaceleração ao se mover na mesma direção e esta com velocidade maior (em pixels por segundo ao quadrado).
@export var friction: float = 800.0 ## Redução da velocidade quando não há input de movimento (em pixels por segundo ao quadrado).
@export var turn_speed: float = 1400.0 ## Aceleração ao mudar de direção (valor maior permite resposta mais rápida ao inverter movimento).

var movement_direction = Vector2.DOWN
var last_movement_direction = Vector2.DOWN

func setup(character:CharacterBody2D) -> void:
	## Define o modo de movimento como "flutuante", ou seja, não aplica gravidade automaticamente
	character.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func set_movement_direction(new_direction:Vector2) -> void:
	movement_direction = new_direction
	if new_direction != Vector2.ZERO:
		last_movement_direction = new_direction

func move_and_slide(character:CharacterBody2D) -> void:
	character.move_and_slide()
	
func is_able_to_walk() -> bool:
	return movement_direction != Vector2.ZERO

func horizontal_movement(character:CharacterBody2D, delta:float,  direction_axis:float = movement_direction.x) -> void:
	_set_axis_movement(character, Vector2.AXIS_X, delta, direction_axis)

func vertical_movement(character:CharacterBody2D, delta:float,  direction_axis:float = movement_direction.y) -> void:
	_set_axis_movement(character, Vector2.AXIS_Y, delta, direction_axis)

func _set_axis_movement(character:CharacterBody2D, axis:int, delta:float,  direction_axis:float) -> void:
	var axis_velocity = character.velocity[axis]
	
	# Calcula a velocidade alvo: direção * velocidade
	var target_speed = direction_axis * speed
	
	if target_speed != 0:
		if axis_velocity != 0 and sign(axis_velocity) != sign(target_speed):
			axis_velocity = move_toward(axis_velocity, 0, turn_speed * delta)
		else:
			if abs(axis_velocity) > abs(target_speed):
				# Se estamos mais rápidos que o alvo, usamos fricção para desacelerar
				axis_velocity = move_toward(axis_velocity, target_speed, deceleration * delta)
			else:
				## Aceleramos até à velocidade desejada
				axis_velocity = move_toward(axis_velocity, target_speed, acceleration * delta)
	else:
		# Se não há movimento desejado, aplicamos fricção para parar gradualmente
		axis_velocity = move_toward(axis_velocity, 0, friction * delta)
		
	character.velocity[axis] = axis_velocity
