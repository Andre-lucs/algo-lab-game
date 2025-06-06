## A popup menu that appears when the right mouse button is pressed.
extends Node
class_name ObjectPopupMenu

enum DefaultItems {
	AUTO,
	DELETE
}

const default_items_resources := {
	DefaultItems.AUTO: preload("uid://bx7gdn3lpxwhc"),
	DefaultItems.DELETE: preload("uid://c6ey0hs2g3kt5")
}

@onready var popup_panel : PopupPanel = $PopupPanel
@onready var default_items_box : HBoxContainer = %DefaultItems
@onready var custom_items_box : HBoxContainer = %CustomItems

@export var interaction_area : MouseInteractionArea2D
@export var default_buttons_to_show : Array[DefaultItems] = [DefaultItems.AUTO, DefaultItems.DELETE]
## Reference needed to set the auto button state
@export var activatable : Activatable
## These buttons will be added between the auto and delete buttons
@export var custom_items : Array[ObjectPopupMenuItem] = []
var default_items : Array[ObjectPopupMenuItem] = []

var mouse_over : bool = false

signal clicked_delete
signal clicked_item(item: ObjectPopupMenuItem, idx: int)

func _ready() -> void:
	if custom_items.size():
		var new_custom_items = custom_items.map(func(i): return i.duplicate(true))
		custom_items = []
		custom_items.assign(new_custom_items)
		prints(custom_items, new_custom_items)
	
	
	# Remove duplicates from default items
	for i in default_buttons_to_show.duplicate():
		if default_buttons_to_show.count(i) > 1:
			default_buttons_to_show.erase(i)
	if not activatable:
		print_debug("Activatable not set, auto button will not work")
		default_buttons_to_show.erase(DefaultItems.AUTO)
		
	# Create default items from resources
	for item in default_buttons_to_show:
		if not default_items_resources.has(item):
			continue
		var resource = default_items_resources[item]
		if resource is ObjectPopupMenuItem:
			var item_instance = resource.duplicate(true) as ObjectPopupMenuItem
			match item:
				DefaultItems.AUTO:
					item_instance.custom_callback = _pressed_auto.bind(item_instance)
					item_instance.initial_frame = Activatable.AutoState.values().find(activatable.auto)
					activatable.changed_auto_state.connect(func(): item_instance.set_frame(activatable.auto, _get_default_button(DefaultItems.AUTO)))
				DefaultItems.DELETE:
					item_instance.custom_callback = _pressed_delete
			default_items.push_back(item_instance)
	
	update_menu_items()

func update_menu_items() -> void:
	for child in default_items_box.get_children() + custom_items_box.get_children():
		child.queue_free()

	if default_items.is_empty():
		default_items_box.get_parent().hide()
	if custom_items.is_empty():
		custom_items_box.get_parent().hide()

	for i in range(default_items.size()):
		var item = default_items[i]
		var button = _generate_button(item, i)
		default_items_box.add_child(button)

	for i in range(custom_items.size()):
		var item = custom_items[i]
		var button = _generate_button(item, i)
		custom_items_box.add_child(button)
	
	
func show_popup() -> void:
	if popup_panel.is_visible():
		return
	var click_pos = get_viewport().get_mouse_position()
	# moves the popup panel to above the mouse position
	popup_panel.position = click_pos - (Vector2(popup_panel.size) / 2)
	
	popup_panel.position.y = max(popup_panel.position.y, 0)  # Prevents popup from going off-screen top
	popup_panel.position.y = min(popup_panel.position.y, get_viewport().size.y - popup_panel.size.y)  # Prevents popup from going off-screen bottom
	popup_panel.position.x = max(popup_panel.position.x, 0)  # Prevents popup from going off-screen left
	popup_panel.position.x = min(popup_panel.position.x, get_viewport().size.x - popup_panel.size.x)  # Prevents popup from going off-screen right

	popup_panel.popup()

func _unhandled_input(_event: InputEvent) -> void:
	if interaction_area and Input.is_action_just_pressed("object_menu"):
		if interaction_area.is_mouse_over():
			show_popup()

func _on_custom_button_pressed(idx : int) -> void:
	var item := custom_items[idx]
	var button := custom_items_box.get_child(idx) as TextureButton
	item.next_frame(button)
	clicked_item.emit(item, idx)

func _generate_button(item : ObjectPopupMenuItem, idx : int) -> TextureButton:
	var button = TextureButton.new()
	item.init_button(button)
	
	if item.custom_callback:
		button.pressed.connect(item.custom_callback)
	elif item in custom_items:
		button.pressed.connect(_on_custom_button_pressed.bind(idx))
	
	button.name = str(custom_items.size())
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.size = Vector2(32, 32)
	button.stretch_mode = TextureButton.STRETCH_SCALE
	return button

func _pressed_auto(item : ObjectPopupMenuItem) -> void:
	item.next_frame(_get_default_button(DefaultItems.AUTO))
	if Activatable.AutoState.values().has(item.current_frame):
		activatable.auto = item.current_frame as Activatable.AutoState
func _pressed_delete():
	clicked_delete.emit()

func _resize() -> void:
	popup_panel.size.x = max(custom_items_box.get_parent().size.x, default_items_box.get_parent().size.x)

func _get_default_button(item: DefaultItems) -> TextureButton:
	var idx = default_buttons_to_show.find(item)
	if idx < 0 or idx >= default_items_box.get_child_count():
		return null
	return default_items_box.get_child(idx) as TextureButton
