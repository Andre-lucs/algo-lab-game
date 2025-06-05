extends Node
class_name Grabbable

@export var parent : Node2D
## If wants the grab release to have some interaction use a GrabbingAreaDetector
@export var interaction_area : MouseInteractionArea2D 

signal released(original_position: Vector2,  new_position: Vector2)

var active : bool = false
var offset : Vector2 = Vector2.ZERO  # Offset between mouse and parent position
var original_position : Vector2 = Vector2.ZERO

func _process(_delta):
	if active and parent:
		# Update the parent's position while maintaining the offset
		var mouse_position = parent.get_global_mouse_position()
		parent.global_position = mouse_position + offset

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("object_grab"):
		if interaction_area and interaction_area.is_mouse_over():
			_on_button_down()
	
	if Input.is_action_just_released("object_grab"):
		if interaction_area and interaction_area.is_mouse_over():
			_on_button_up()

func _on_button_down() -> void:
	if parent:
		# Calculate the offset when the button is pressed
		var mouse_position = parent.get_global_mouse_position()
		offset = parent.global_position - mouse_position
		original_position = parent.global_position
		active = true

func _on_button_up() -> void:
	active = false
	released.emit(original_position, parent.global_position)
	var release_areas = interaction_area.get_overlapping_areas().filter(func(a): return a is GrabbingAreaDetector)
	if not release_areas.is_empty():
		var release_area := release_areas.front() as GrabbingAreaDetector
		release_area.catch_object(parent, original_position)

func is_being_dragged() -> bool:
	return active

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if not parent:
		warnings.append("Parent is not set.")
	if not interaction_area:
		warnings.append("Interaction area is not set.")
	return warnings
