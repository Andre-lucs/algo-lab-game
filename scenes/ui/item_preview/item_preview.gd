extends Control
class_name ItemPreview

@export var item : PackedScene

var mouse_button_pressed : bool = false  # Track if the left mouse button is pressed

func _ready() -> void:
	# Check if the left mouse button is already pressed when the preview is instantiated
	mouse_button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_button_pressed = true
			elif mouse_button_pressed and not event.is_pressed():
				# Handle left mouse button release
				mouse_button_pressed = false
				print("Left mouse button released")
				print("creating ", item.resource_path)
				var item_instance = item.instantiate()
				get_tree().current_scene.add_child(item_instance)
				item_instance.global_position = get_global_mouse_position()
				queue_free()
