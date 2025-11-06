# Define uma classe chamada State que herda de Node
class_name State extends Node2D

var state_machine:StateMachine = null

signal state_enter(last_state_name:String)
signal state_exit

func _ready() -> void:
	if not get_parent() is StateMachine:
		push_error("parent need to be StateMachine")
		return

func get_state_name() -> String:
	return get_name().to_lower()

# Função chamada quando o state estiver pronto
func _on_state_ready() -> void:
	pass

# Função chamada a cada frame (pode ser sobrescrita por estados concretos)
func _on_state_process(_delta : float) -> void:
	pass

# Função chamada a cada frame de física (para lógicas dependentes da física)
func _on_state_physics_process(_delta : float) -> void:
	pass

# Função que define as condições para transições entre estados
func _on_state_next_transitions() -> void:
	pass

# Função que define as condições para transições entre estados
func _on_state_check_transitions(_current_state_name:String, _current_state:Node) -> void:
	pass

# Função chamada ao entrar neste estado
func _on_state_enter(_last_state_name:String) -> void:
	pass

# Função chamada ao sair deste estado
func _on_state_exit() -> void:
	pass

func transition_to(state_name:String) -> void:
	if state_machine:
		state_machine.transition_to(state_name)
