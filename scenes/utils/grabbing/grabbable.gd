extends Node
class_name Grabbable

enum GrabPriority {
	LOW,
	MEDIUM,
	HIGH
}

enum GrabbingSpeed {
	FAST,
	NORMAL,
	SLOW
}

const DELAY_SPEEDS = {
	GrabbingSpeed.FAST: 0.1,
	GrabbingSpeed.NORMAL: 0.2,
	GrabbingSpeed.SLOW: 0.3
}

@export var parent : Node2D
## If wants the grab release to have some interaction use a GrabbingAreaDetector or just activate the correct layer
@export var interaction_area : MouseInteractionArea2D 
@export var grab_priority : GrabPriority = GrabPriority.MEDIUM
@export var grab_speed : GrabbingSpeed = GrabbingSpeed.NORMAL

signal released(original_position: Vector2,  new_position: Vector2)

var active : bool = false
var offset : Vector2 = Vector2.ZERO  # Offset between mouse and parent position
var original_position : Vector2 = Vector2.ZERO
var _grab_timer: float = 0.0
var _waiting_for_grab: bool = false

func _enter_tree() -> void:
	if not is_in_group("grabbable"):
		add_to_group("grabbable")

func _ready() -> void:
	if interaction_area:
		interaction_area.area_exited.connect(_on_leaving_grabbing_area_detector)

func _process(delta):
	if active and parent:
		# Update the parent's position while maintaining the offset
		var mouse_position = parent.get_global_mouse_position()
		parent.global_position = mouse_position + offset
	elif _waiting_for_grab:
		_grab_timer += delta

func _input(_event: InputEvent) -> void:
	if not interaction_area:
		return
	if Input.is_action_just_pressed("object_grab"):
		if interaction_area and interaction_area.is_mouse_over():
			if validate_dragging():
				_waiting_for_grab = true
				_grab_timer = 0.0
				MouseLoadingIndicator.animate(DELAY_SPEEDS[grab_speed], 
				func():
					_waiting_for_grab = false
					_grab_timer = 0.0
					if validate_dragging():
						begin_dragging()
					else:
						invalidate_grab()
					)
	
	if Input.is_action_just_released("object_grab") :
		_waiting_for_grab = false
		_grab_timer = 0.0
		MouseLoadingIndicator.kill()
		if active:
			_on_button_up()

func validate_dragging(soft_checking := false) -> bool:
	# For soft_checking we just check if there are no other grabbables being dragged
	if soft_checking:
		return _is_other_grab_active()
	# Prevent dragging if a level is being executed
	if LevelManager.current_level_instance and LevelManager.current_level_instance.level_executor.execution_in_progress:
		return false

	if not parent:
		return false
	if not interaction_area:
		return false
	if not interaction_area.is_mouse_over():
		return false
	if _is_other_grab_active():
		return false
	
	return true

func _is_other_grab_active() -> bool:
	var grabbables = get_tree().get_nodes_in_group("grabbable")
	for grabbable in grabbables:
		if grabbable is Grabbable and (grabbable.is_being_dragged() or grabbable._waiting_for_grab) and grabbable != self:
			if grab_priority < grabbable.grab_priority:
				return true
	return false

func begin_dragging() -> void:
	# Calculate the offset when the button is pressed
	var mouse_position = parent.get_global_mouse_position()
	offset = parent.global_position - mouse_position
	original_position = parent.global_position
	active = true
	filter_grabbing_by_priority.call_deferred()

## If the grabbable is not the highest priority, it will stop dragging
## and return false, otherwise it will return true
func filter_grabbing_by_priority() -> bool:
	var grab_nodes = get_tree().get_nodes_in_group("grabbable").filter(func(g): return g.active)
	if grab_nodes.is_empty():
		return true
	grab_nodes.sort_custom(func(g1, g2): return int(g2.grab_priority - g1.grab_priority))
	if grab_nodes.front() != self:
		# If this grabbable is not the highest priority, stop dragging
		invalidate_grab()
		return false
	return true

func _on_button_up() -> void:
	active = false
	released.emit(original_position, parent.global_position)
	var release_areas = interaction_area.get_overlapping_areas().filter(func(a): return a is GrabbingAreaDetector)
	if not release_areas.is_empty():
		var release_area := release_areas.front() as GrabbingAreaDetector
		release_area.catch_object(parent, original_position)

func invalidate_grab():
	if not is_being_dragged():
		return
	if parent: parent.global_position = original_position
	active = false
	_waiting_for_grab = false
	_grab_timer = 0.0

func _on_leaving_grabbing_area_detector(area : Area2D):
	if not area is GrabbingAreaDetector or not active:
		return
	var detector := area as GrabbingAreaDetector
	detector.removed_object_from_area(parent, original_position)

func is_being_dragged() -> bool:
	return active

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if not parent:
		warnings.append("Parent is not set.")
	if not interaction_area:
		warnings.append("Interaction area is not set.")
	return warnings
