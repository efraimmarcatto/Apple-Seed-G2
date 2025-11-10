class_name BaseCamera2DTrigger
extends Node2D


@export var signal_trigger: NodeSignal = null ## node e evento que ativa o trigger
@export var active: bool = true
@export var trigger_once: bool = false
@export var delay: float = 0.0

@export_category("Effects")
# --- Zoom ---
@export_group("Zoom")
@export var zoom_enabled: bool = false
@export var zoom_target: Vector2 = Vector2(1.5, 1.5)
@export var zoom_speed: float = 2

# --- Shake ---
@export_group("Shake")
@export var shake_enabled: bool = false
@export var shake_duration: float = 0.4
@export var shake_strength: float = 6.0

# --- Focus ---
@export_group("Focus")
@export var focus_enabled: bool = false
@export var focus_target: NodePath
@export var focus_animation_duration: float = 1.5

# --- Transition ---
@export_group("Transition")
@export var transition_enabled: bool = false
@export var transition_camera: BaseCamera2D
@export var transition_animation_duration: float = 1.0

var _has_triggered: bool = false

signal trigged

func _ready() -> void:
	if signal_trigger:
		signal_trigger.connect_signal(self, _on_trigger_active)
	
				
func _on_trigger_active() -> void:
	if not active:
		return
		
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	if not trigger_once or (trigger_once and not _has_triggered):
		_trigger_all()
	
	_has_triggered = true
	trigged.emit()

func _trigger_all() -> void:
	if transition_enabled:
		var cam := transition_camera
		if cam and is_instance_valid(cam):
			CameraManager.change_camera(cam, transition_animation_duration)
			
	if zoom_enabled:
		CameraManager.zoom(zoom_target, zoom_speed)

	if shake_enabled:
		CameraManager.shake(shake_duration, shake_strength)

	if focus_enabled:
		var node := get_node_or_null(focus_target)
		if node:
			CameraManager.focus_on(node.global_position, focus_animation_duration)
