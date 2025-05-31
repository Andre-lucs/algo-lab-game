# the one who requests the activation of objetcs
extends Node
class_name Activatable

enum AutoState {
	OFF,
	ONE_SHOT,
	ON
}

signal activated
## May be used to change the appearance of the object to sign that it is automatic or not
signal changed_auto_state(state: AutoState)
signal paused_activation

@export var target : Node
@export var trigger_signals : Array[String]
@export var base_delay : float = 0.2
@export var auto : AutoState = AutoState.ON :
	set(value):
		changed_auto_state.emit(value)
		auto = value


var activation_queue : int = 0
var is_paused : bool = false

@onready var activation_timer : Timer = $ActivationTimer

func _ready() -> void:
	activation_timer.wait_time = base_delay

func start_activation_if_auto() -> void:
	activation_timer.one_shot = is_manual()
	if auto == AutoState.OFF:
		return
	activate()

func activate(times : int = 1) -> void:
	# # Forces re activation if the timer is paused
	# if is_paused:
	# 	is_paused = false
	activation_queue += times
	print("queued activations: ", activation_queue)
	if not activation_timer.is_stopped():
		return
	activation_timer.start()
	
func _send_activation() -> void:
	# If is paused, don't send activation and don't consume the activation queue
	if is_paused:
		return
	if activation_queue <= 0:
		print("No activations in queue for: ", get_parent().name)
		return
	activated.emit()
	print("Activated: ", get_parent().name)
	activation_queue -= 1 if auto != AutoState.ON else 0 
	# If there are more activations in the queue, start the timer again
	if activation_queue == 0 or is_paused:
		return
	activation_timer.start()
	
func pause_activation() -> void:
	paused_activation.emit()
	activation_timer.stop()
	is_paused = true
	print("Activation paused for: ", get_parent().name)

func resume_activation() -> void:
	if not is_paused:
		return
	print("Resuming activation for: ", get_parent().name)
	is_paused = false
	_send_activation()

func _on_activation_timer_timeout() -> void:
	_send_activation()

func get_trigger_signals() -> Array[String]:
	return trigger_signals

func is_manual() -> bool:
	return auto != AutoState.ON

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if target == null:
		warnings.append("Target not set")
	if trigger_signals.size() == 0:
		warnings.append("No trigger signals set")
	return warnings

func reset() -> void:
	# Reset the activation state
	activation_queue = 0
	is_paused = false
	activation_timer.stop()