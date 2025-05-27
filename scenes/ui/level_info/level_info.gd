class_name LevelInfo extends HBoxContainer

const LERP_SPEED := 0.2
const ARROW_HIDE_THRESHOLD := 1.5

@export var level_props : LevelPropsResource = null:
	set(value):
		if value:
			level_props = value
			title_label.text = level_props.level_name
			description_label.text = level_props.level_description
@export var container_width : int = 200
@export var resizable : bool = true:
	set(value):
		if not is_node_ready():
			await ready
		if value:
			$DragSeparator.visible = true
			$DragSeparator.connect("gui_input", _on_drag_separator_gui_input)
		else:
			$DragSeparator.visible = false
			$DragSeparator.disconnect("gui_input", _on_drag_separator_gui_input)
@export_range(0,1) var screen_size_limit : float = 0.5
@export var right_side_gap : float = 80

@onready var title_label : RichTextLabel = %Title
@onready var description_label : RichTextLabel = %Description
@onready var arrow : Button = $Arrow
@onready var screen_width : float = get_viewport_rect().size.x
var being_dragged : bool = false
var initial_minimum_size : Vector2
var target_position : float = 0.0 :
	set(value):
		if not screen_width: screen_width = get_viewport_rect().size.x
		target_position = clamp(value, screen_width - (screen_width * screen_size_limit), screen_width - right_side_gap)
var is_hidden : bool = false

func _ready() -> void:
	get_window().size_changed.connect(_on_window_size_changed)
	target_position = position.x
	arrow.pivot_offset = Vector2(arrow.get_rect().size.x / 2, arrow.get_rect().size.y / 2)
	custom_minimum_size = Vector2(container_width, 0)
	size.x = custom_minimum_size.x
	initial_minimum_size = custom_minimum_size
	show_container()

func _process(_delta: float) -> void:
	if abs(position.x - target_position) > 1: 
		position.x = lerp(position.x, target_position, LERP_SPEED) 
	else: 
		position.x = target_position 
		# If the position is close enough to the rigthside gap, we can consider the arrow as pressed and hide the container
		if position.x > screen_width - right_side_gap*ARROW_HIDE_THRESHOLD: 
			arrow.button_pressed = true

func hide_container() -> void:
	target_position = screen_width
func show_container() -> void:
	target_position = screen_width - size.x

func _on_arrow_toggled(toggled_on: bool) -> void:
	is_hidden = toggled_on
	create_tween().tween_property(arrow, "rotation_degrees", 180 if toggled_on else 0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	if toggled_on:
		hide_container()
	else:
		show_container()

func _on_drag_separator_gui_input(event: InputEvent) -> void:
	if is_hidden:
		being_dragged = false
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			being_dragged = true
		else:
			being_dragged = false
	elif event is InputEventMouseMotion and being_dragged:
		custom_minimum_size.x = clamp(custom_minimum_size.x - event.relative.x, initial_minimum_size.x, get_viewport_rect().size.x * screen_size_limit)
		size.x = custom_minimum_size.x
		target_position += event.relative.x

func _on_window_size_changed() -> void:
	_on_arrow_toggled(is_hidden)
	screen_width = get_viewport_rect().size.x
