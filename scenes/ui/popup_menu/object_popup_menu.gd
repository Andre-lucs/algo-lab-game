## A popup menu that appears when the right mouse button is pressed.
extends Node
class_name ObjectPopupMenu

@onready var popup_panel : PopupPanel = $PopupPanel
@onready var hbox : HBoxContainer = $PopupPanel/HBoxContainer

@export var show_auto_button : bool = true
@export var activatable : Activatable
@export var show_delete_button : bool = true
## These buttons will be added between the auto and delete buttons
@export var items : Array[ObjectPopupMenuItem] = []
@export var interaction_area : MouseInteractionArea2D

var mouse_over : bool = false

signal clicked_option(idx: int)
signal clicked_delete
signal clicked_item(item: ObjectPopupMenuItem, idx: int)

func _ready() -> void:
	items = items.duplicate()
	if show_auto_button:
		var auto_button = preload("res://scenes/ui/popup_menu/auto_button_menu_item.tres").duplicate()
		items.push_front(auto_button)
		if activatable:
			auto_button.initial_frame = activatable.auto
		else:
			printerr("No activatable node found in ", get_path())
	if show_delete_button:
		var delete_button = preload("res://scenes/ui/popup_menu/delete_button_menu_item.tres").duplicate()
		items.push_back(delete_button)
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
	clicked_item.emit(item, idx)

func _generate_button(item : ObjectPopupMenuItem, idx : int) -> TextureButton:
	var button = TextureButton.new()
	item.init_button(button)
	if show_auto_button and idx == 0:
		button.pressed.connect(_pressed_auto)
	elif show_delete_button and idx == items.size() - 1:
		button.pressed.connect(_pressed_delete)
	else:
		button.pressed.connect(_on_button_pressed.bind(idx))
	button.name = str(items.size())
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.size = Vector2(32, 32)
	button.stretch_mode = TextureButton.STRETCH_SCALE
	return button

func _pressed_auto():
	var button := hbox.get_child(0) as TextureButton
	var item = items[0] as ObjectPopupMenuItem
	item.next_frame(button)
	if Activatable.AutoState.values().has(item.current_frame):
		activatable.auto = item.current_frame as Activatable.AutoState
func _pressed_delete():
	clicked_delete.emit()