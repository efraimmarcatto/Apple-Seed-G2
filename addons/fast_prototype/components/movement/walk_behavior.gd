@tool
extends Node
class_name WalkBehavior

# ========================================================
# === VARIÁVEIS PRINCIPAIS ===
# Este script controla o movimento automático de um personagem (NPC ou inimigo)
# baseado em uma lista de direções (Vector2) e durações (float) configuráveis no editor.

@export var enabled: bool = true ## Define se o comportamento está ativo ou não
@export var target: CharacterBody2D  ## O corpo que será movimentado
@export var character_movement_controller: CharacterMovementController  ## Script que aplica a direção no personagem

# ========================================================
# === CONFIGURAÇÕES DE COLISÃO ===
@export_category("stop on collision")
@export var stop_on_collision_area:Area2D ## area para identificar a colisão
@export var resume_after: float = 3.0 ## Tempo (em segundos) para retomar o movimento após colisão

# ========================================================
# === CONFIGURAÇÕES DE DIREÇÕES ===
@export_category("Directions")
@export var loop: bool = true ## Se true, o movimento reinicia ao final da sequência

# ========================================================
# === SINAIS ===
signal finished_cycle  # Emite quando o ciclo completo de movimentos termina

# ========================================================
# === DADOS INTERNOS ===
var directions: Array[Vector2] = []  # Lista de direções (cada direção é um Vector2)
var durations: Array[float] = []     # Lista de tempos correspondentes a cada direção

var current_index: int = 0           # Índice atual da direção sendo executada
var current_time: float = 0.0        # Tempo acumulado para o passo atual
var is_paused: bool = false          # Flag que indica se o movimento está pausado (ex: por colisão)

# ========================================================
# === INSPECTOR CUSTOMIZADO (EDITOR) ===
#region Tool
# Cria uma propriedade "totalSteps" visível e reordenável no editor
# Cada item é um dicionário com {"direction": Vector2, "time": float}
@export var totalSteps: Array[Dictionary] = [] : set = _set_total_steps, get = _get_total_steps

# Setter: Atualiza as listas internas (directions e durations) quando o array muda no editor
func _set_total_steps(value: Array[Dictionary]) -> void:
	totalSteps = value
	directions.clear()
	durations.clear()
	for step in value:
		# Pega os valores "direction" e "time" de cada dicionário
		# Se algum estiver faltando, usa padrão (Vector2.ZERO e 1.0)
		directions.append(step.get("direction", Vector2.ZERO))
		durations.append(step.get("time", 1.0))

# Getter: Reconstrói a lista totalSteps a partir dos arrays internos
# Isso permite que o editor mostre e salve as informações corretamente
func _get_total_steps() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(directions.size()):
		result.append({
			"direction": directions[i],
			"time": durations[i],
		})
	return result
#endregion

# ========================================================
# === CICLO DE VIDA ===
func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	if stop_on_collision_area and stop_on_collision_area.has_signal("body_entered"):
		stop_on_collision_area.body_entered.connect(_on_body_entered)

# ========================================================
# === LOOP PRINCIPAL DE MOVIMENTO ===
func _process(delta: float) -> void:
	# Se estiver no editor (modo de edição), não executa movimento
	if Engine.is_editor_hint():
		return

	# Se o comportamento estiver desativado ou pausado, não faz nada
	if not enabled or is_paused:
		return

	# Se não houver direções ou tempos configurados, sai
	if directions.is_empty() or durations.is_empty():
		return
	
	if directions.size() <= current_index or durations.size() <= current_index:
		current_time = 0.0
		current_index = 0

	# Pega a direção e o tempo do passo atual
	var dir = directions[current_index]
	var time = durations[current_index]
	
	# caso nao tenha algum dos dois valores
	if not dir and not time:
		return

	# Envia a direção para o controlador de movimento (responsável por aplicar no CharacterBody2D)
	if character_movement_controller and character_movement_controller.has_method("set_movement_direction"):
		character_movement_controller.set_movement_direction(dir)

	# Incrementa o tempo atual
	current_time += delta

	# Quando o tempo do passo atual termina, passa para o próximo
	if current_time >= time:
		current_time = 0.0
		current_index += 1

		# Se chegou ao fim da sequência de direções
		if current_index >= directions.size():
			if loop:
				# Reinicia o ciclo e emite sinal de ciclo completo
				current_index = 0
				emit_signal("finished_cycle")
			else:
				# Se não estiver em loop, desativa o comportamento
				enabled = false
				emit_signal("finished_cycle")

# ========================================================
# === MÉTODOS PÚBLICOS (API EXTERNA) ===

# Ativa o comportamento e reseta variáveis internas
func enable() -> void:
	enabled = true
	current_index = 0
	current_time = 0.0
	is_paused = false

# Desativa o comportamento e zera a direção de movimento
func disable() -> void:
	enabled = false
	if character_movement_controller and character_movement_controller.has_method("set_movement_direction"):
		character_movement_controller.set_movement_direction(Vector2.ZERO)

# Pausa o movimento por um tempo específico (usado em colisões)
func pause_for(seconds: float) -> void:
	is_paused = true
	if character_movement_controller:
		# Para o movimento durante a pausa
		character_movement_controller.set_movement_direction(Vector2.ZERO)
	if stop_on_collision_area:
		stop_on_collision_area.set_deferred("monitoring", false)
	# Cria um timer temporário e espera ele terminar antes de retomar
	await get_tree().create_timer(seconds).timeout
	is_paused = false
	if stop_on_collision_area:
		stop_on_collision_area.set_deferred("monitoring", true)

# ========================================================
# === DETECÇÃO DE COLISÃO ===
func _on_body_entered(_body: Node) -> void:
	# Quando colidir, pausa o movimento se a opção estiver ativada
	if stop_on_collision_area:
		pause_for(resume_after)
