## A popup menu that appears when the right mouse button is pressed.
extends Node
class_name ObjectPopupMenu

#region Enums and Constants
enum DefaultItems {
	ROTATE,
	AUTO,
	DELETE
}

enum RotationDirection {
	CLOCKWISE,
	ANTICLOCKWISE
}

const default_items_resources := {
	DefaultItems.ROTATE: preload("uid://csqrpeyufd3uk"),
	DefaultItems.AUTO: preload("uid://bx7gdn3lpxwhc"),
	DefaultItems.DELETE: preload("uid://c6ey0hs2g3kt5")
}

const BUTTON_SIZE := Vector2(32, 32)  # Size of the buttons in the popup menu

@onready var popup_panel : PopupPanel = $PopupPanel
@onready var default_items_box : HBoxContainer = %DefaultItems
@onready var custom_items_box : HBoxContainer = %CustomItems
#endregion

@export var interaction_area : MouseInteractionArea2D
@export var default_buttons_to_show : Array[DefaultItems] = [DefaultItems.AUTO, DefaultItems.DELETE]
@export var custom_items : Array[ObjectPopupMenuItem]
## Reference needed to set the auto button state
@export var activatable : Activatable

@export_group("Rotation")
@export var rotation_target : Node2D
@export var rotation_direction : RotationDirection = RotationDirection.CLOCKWISE
@export_subgroup("Customize Rotation")
@export_range(0, 360, 15) var rotation_angle : float = 90.0
@export var rotation_duration : float = 0.2

var default_items : Array[ObjectPopupMenuItem] = []
var _rotated: bool = false

signal clicked_delete
signal clicked_item(item: ObjectPopupMenuItem, idx: int)

#region Initialization
func _ready() -> void:
	if custom_items.size():
		var new_custom_items = custom_items.map(func(i): return i.duplicate(true))
		custom_items = []
		custom_items.assign(new_custom_items)
	
	_initialize_default_buttons()
	
	update_menu_items()

func _initialize_default_buttons():
	# Remove duplicates from default items
	for i in default_buttons_to_show.duplicate():
		if default_buttons_to_show.count(i) > 1:
			default_buttons_to_show.erase(i)
	# Check if the required items are set
	if not activatable:
		print_debug("Activatable not set, auto button will not work")
		default_buttons_to_show.erase(DefaultItems.AUTO)
	if not rotation_target:
		print_debug("Rotation target not set, rotate button will not work")
		default_buttons_to_show.erase(DefaultItems.ROTATE)
		
	# Create default items from resources
	for item in default_buttons_to_show:
		if not default_items_resources.has(item):
			continue
		var resource = default_items_resources[item]
		if resource is ObjectPopupMenuItem:
			var item_instance = resource.duplicate(true) as ObjectPopupMenuItem
			# Set custom callbacks for each item
			match item:
				DefaultItems.ROTATE:
					item_instance.custom_callback = _pressed_rotate
				DefaultItems.AUTO:
					item_instance.custom_callback = _pressed_auto.bind(item_instance)
					item_instance.initial_frame = Activatable.AutoState.values().find(activatable.auto)
					activatable.changed_auto_state.connect(func(): item_instance.set_frame(activatable.auto, _get_default_button(DefaultItems.AUTO)))
				DefaultItems.DELETE:
					item_instance.custom_callback = _pressed_delete
			default_items.push_back(item_instance)

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

func _generate_button(item : ObjectPopupMenuItem, idx : int) -> TextureButton:
	var button = TextureButton.new()
	item.init_button(button)
	
	if item.custom_callback:
		button.pressed.connect(item.custom_callback)
	elif item in custom_items:
		button.pressed.connect(_on_custom_button_pressed.bind(idx))
	
	button.name = str(custom_items.size())
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.size = BUTTON_SIZE
	button.stretch_mode = TextureButton.STRETCH_SCALE
	return button
#endregion

#region Popup Management
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

func _resize() -> void:
	popup_panel.size.x = max(custom_items_box.get_parent().size.x, default_items_box.get_parent().size.x)
#endregion

#region Input Handling
func _unhandled_input(_event: InputEvent) -> void:
	if interaction_area and Input.is_action_just_pressed("object_menu"):
		if interaction_area.is_mouse_over():
			show_popup()

func _on_custom_button_pressed(idx : int) -> void:
	var item := custom_items[idx]
	var button := custom_items_box.get_child(idx) as TextureButton
	item.next_frame(button)
	clicked_item.emit(item, idx)

func _pressed_auto(item : ObjectPopupMenuItem) -> void:
	item.next_frame(_get_default_button(DefaultItems.AUTO))
	if Activatable.AutoState.values().has(item.current_frame):
		activatable.auto = item.current_frame as Activatable.AutoState
func _pressed_delete():
	clicked_delete.emit()
func _pressed_rotate() -> void:
	if rotation_target:
		var angle = rotation_angle if rotation_direction == RotationDirection.CLOCKWISE else -rotation_angle
		
		if _rotated:
			angle = -angle  # If already rotated, reverse the angle to rotate back
			_rotated = false
		else:
			_rotated = true 
		
		create_tween().tween_property(rotation_target, "rotation_degrees", rotation_target.rotation_degrees + angle, rotation_duration)
#endregion

func _get_default_button(item: DefaultItems) -> TextureButton:
	var idx = default_buttons_to_show.find(item)
	if idx < 0 or idx >= default_items_box.get_child_count():
		return null
	return default_items_box.get_child(idx) as TextureButton
