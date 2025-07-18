extends Control
class_name ItemPreview

@export var item : PackedScene
@export var preview_image : Texture2D
@export var custom_args : Dictionary[String, Variant] = {}

@onready var texture_rect : TextureRect = $TextureRect

var mouse_button_pressed : bool = false  # Track if the left mouse button is pressed

func _ready() -> void:
	# Check if the left mouse button is already pressed when the preview is instantiated
	mouse_button_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	texture_rect.texture = preview_image
		

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		queue_free() # Stop creating item preview when right button is clicked
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_button_pressed = true
			elif mouse_button_pressed and not event.is_pressed():
				# Handle left mouse button release
				mouse_button_pressed = false
				var item_instance = item.instantiate()
				if custom_args:
					for key in custom_args.keys():
						item_instance.set(key, custom_args[key])
				get_tree().current_scene.add_child(item_instance)
				item_instance.global_position = get_global_mouse_position()
				queue_free()
