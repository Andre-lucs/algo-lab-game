# the one who requests the activation of objetcs
extends Node
class_name Activatable

enum AutoState {
	OFF, # The object is manual, it will only activate when requested
	ONE_SHOT, # The object is manual, but will activate once when the level starts
	AUTO, # The object is automatic, it will activate when the level starts and keep being activated
	AUTO_INACTIVE, # The object is automatic, but it will not activate until it is activated manually at least once
}

signal activated
signal success_activated
## May be used to change the appearance of the object to sign that it is automatic or not
signal changed_auto_state(state: AutoState)
signal paused_activation

@export var target : Node
@export var trigger_signals : Array[String]
@export var base_delay : float = 0.2
@export var auto : AutoState = AutoState.AUTO :
	set(value):
		changed_auto_state.emit(value)
		auto = value


var activation_queue : int = 0
var is_paused : bool = false

@onready var activation_timer : Timer = $ActivationTimer

func _ready() -> void:
	activation_timer.wait_time = base_delay

	for trigger_signal in trigger_signals:
		if not target.has_signal(trigger_signal):
			push_error("Target does not have signal: " + trigger_signal)
			continue
		target.connect(trigger_signal, func(_1=null,_2=null,_3=null,_4=null,_5=null,_6=null,_7=null,_8=null):_trigger_success_activation())

func start_activation_if_auto() -> void:
	activation_timer.one_shot = is_manual()
	activation_timer.paused = is_paused
	if auto == AutoState.OFF or auto == AutoState.AUTO_INACTIVE:
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

# This function is called to trigger an activation immediately
func instant_activation() -> void:
	if is_paused:
		print("Activation paused, ignoring instant activation for: ", get_parent().name)
		return
	# If timer is active (in cooldown), respect the cooldown by using activate()
	if not activation_timer.is_stopped():
		activate(1)
		return
	# Otherwise, activate immediately
	activation_queue += 1
	_send_activation()

func _send_activation() -> void:
	# If is paused, don't send activation and don't consume the activation queue
	if is_paused:
		return
	if activation_queue <= 0:
		print("No activations in queue for: ", get_parent().name)
		return
	activated.emit()
	print("Activated: ", get_parent().name)
	activation_queue -= 1 if is_manual() else 0 
	# If there are more activations in the queue, start the timer again
	if activation_queue == 0 or is_paused:
		return
	activation_timer.start()
	
func _trigger_success_activation() -> void:
	# This function is called when the target emits a signal that indicates a successful activation
	if is_paused:
		print("Activation paused, ignoring success signal for: ", get_parent().name)
		return
	success_activated.emit()
	print("Success activation for: ", get_parent().name)

func pause_activation() -> void:
	paused_activation.emit()
	activation_timer.paused = true
	is_paused = true
	print("Activation paused for: ", get_parent().name)

func resume_activation() -> void:
	if not is_paused:
		return
	print("Resuming activation for: ", get_parent().name)
	is_paused = false
	activation_timer.paused = false

func _on_activation_timer_timeout() -> void:
	_send_activation()

func get_trigger_signals() -> Array[String]:
	return trigger_signals

func is_manual() -> bool:
	return not (auto in [AutoState.AUTO, AutoState.AUTO_INACTIVE])

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
