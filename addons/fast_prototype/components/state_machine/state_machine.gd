# Define uma classe personalizada chamada StateMachine que herda de Node2D
class_name StateMachine extends Node2D

# Exporta a variável initial_state para poder ser configurada no editor
@export var initial_state : State

# Dicionário para armazenar os estados pela chave (nome em minúsculas)
var node_states : Dictionary = {}

# Estado atual e o respetivo nome
var current_state : State
var current_state_name : String
var last_state_name : String

signal state_changed(state_name:String) ## sinal de troca de state

# Função chamada quando o nó entra na cena
func _ready() -> void:
	if not Engine.is_editor_hint():
		for child in get_children():
			# Verifica se o filho é um estado
			if child is State:
				# Guarda o estado no dicionário com a chave em minúsculas
				node_states[child.get_state_name().to_lower()] = child
				# Liga o state ao state_machine
				child.state_machine = self
				child._on_state_ready()
				
		# Inicia o estado inicial, se definido
		if initial_state:
			initial_state._on_state_enter(last_state_name)
			current_state = initial_state
			current_state_name = initial_state.get_state_name().to_lower()

# Atualização por frame (chamada a cada frame)
func _process(delta : float) -> void:
	if not Engine.is_editor_hint():
		if current_state:
			current_state._on_state_process(delta)

# Atualização de física (chamada a cada frame de física)
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if current_state:
			current_state._on_state_physics_process(delta)
			current_state._on_state_next_transitions()
	
			for i in node_states:
				node_states[i]._on_state_check_transitions(current_state.get_state_name(), current_state)
	
# Função responsável por mudar de estado
func transition_to(state_name : String) -> void:
	# Impede transições para o mesmo estado
	if state_name == current_state.get_state_name().to_lower():
		return
	
	# Obtém o novo estado pelo nome
	var new_state = node_states.get(state_name.to_lower())
	
	# Se o estado não existir, sai
	if !new_state:
		return
	
	# Sai do estado atual
	if current_state:
		current_state._on_state_exit()
		current_state.state_exit.emit()
		last_state_name = current_state_name
	
	# Entra no novo estado
	new_state._on_state_enter(last_state_name)
	new_state.state_enter.emit(last_state_name)
	state_changed.emit(state_name)
	
	# Atualiza a referência ao estado atual
	current_state = new_state
	current_state_name = current_state.get_state_name().to_lower()
	#print("Current State: ", current_state_name)  # Comentado para debug opcional
