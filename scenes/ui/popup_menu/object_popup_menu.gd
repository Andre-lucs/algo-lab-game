## A popup menu that appears when the right mouse button is pressed.
extends Node
class_name ObjectPopupMenu

@onready var popup_panel : PopupPanel = $PopupPanel
@onready var hbox : HBoxContainer = $PopupPanel/HBoxContainer

@export var items : Array[ObjectPopupMenuItem] = []
@export var interaction_area : MouseInteractionArea2D
var mouse_over : bool = false

signal clicked_option(idx: int)

func _ready() -> void:
	if not items.is_empty():
		update_menu_items()

func update_menu_items() -> void:
	for child in hbox.get_children():
		child.queue_free()

	for i in range(items.size()):
		var item = items[i]
		var button = _generate_button(item, i)
		hbox.add_child(button)
	
func show_popup() -> void:
	if popup_panel.is_visible():
		popup_panel.hide()
	else:
		# moves the popup panel to above the mouse position
		popup_panel.position = get_tree().current_scene.get_global_mouse_position() - Vector2(0, popup_panel.size.y)
		popup_panel.popup()

func _input(_event: InputEvent) -> void:
	if interaction_area and Input.is_action_just_pressed("object_menu"):
		if interaction_area.is_mouse_over():
			show_popup()

func _on_button_pressed(idx : int) -> void:
	var item := items[idx]
	var button := hbox.get_child(idx) as TextureButton
	item.next_frame(button)
	clicked_option.emit(idx)

func _generate_button(item : ObjectPopupMenuItem, idx : int) -> TextureButton:
	var button = TextureButton.new()
	item.init_button(button)
	button.pressed.connect(_on_button_pressed.bind(idx))
	button.name = str(items.size())
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.size = Vector2(32, 32)
	button.stretch_mode = TextureButton.STRETCH_SCALE
	return button
