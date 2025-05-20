# the one who requests the activation of objetcs
extends Node
class_name Activatable

signal activated
## May be used to change the appearance of the object to sign that it is automatic or not
signal changed_auto_state(state: bool)

@export var target : Node
@export var trigger_signals : Array[String]
@export var base_delay : float = 0.2
@export var auto : bool = true : set = _set_auto


var activation_queue : int = 0

@onready var activation_timer : Timer = $ActivationTimer

func _ready() -> void:
	activation_timer.wait_time = base_delay
	# If the activation is not automatic the timer will be one shot
	activation_timer.one_shot = !auto

func start_activation_if_auto() -> void:
	if not auto:
		return
	activation_timer.one_shot = !auto
	activation_queue = 1
	activation_timer.start()

func activate(times : int = 1) -> void:
	activation_queue += times
	print("queued activations: ", activation_queue)
	if not activation_timer.is_stopped():
		return
	activation_timer.start()
	
func _send_activation() -> void:
	activated.emit()
	print("Activated: ", get_parent().name)
	activation_queue -= 1
	# If there are more activations in the queue, start the timer again
	if activation_queue == 0:
		return
	activation_timer.start()
	
func _on_activation_timer_timeout() -> void:
	_send_activation()

func _set_auto(value : bool) -> void:
	auto = value
	changed_auto_state.emit(auto)

func get_trigger_signals() -> Array[String]:
	return trigger_signals

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if target == null:
		warnings.append("Target not set")
	if trigger_signals.size() == 0:
		warnings.append("No trigger signals set")
	return warnings