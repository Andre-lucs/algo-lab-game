class_name LevelInfo extends HBoxContainer

@export var level_props : LevelPropsResource = null:
	set(value):
		if value:
			level_props = value
			title_label.text = level_props.level_name
			description_label.text = level_props.level_description
@export var container_width : int = 200
@export_range(0,1) var screen_size_limit : float = 0.5
@export var right_side_gap : float = 80

@onready var title_label : RichTextLabel = %Title
@onready var description_label : RichTextLabel = %Description
@onready var arrow : Button = $Arrow

var being_dragged : bool = false
var initial_minimum_size : Vector2
var target_position : float = 0.0 :
	set(value):
		target_position = clamp(value, get_viewport_rect().size.x - (get_viewport_rect().size.x * screen_size_limit), get_viewport_rect().size.x - right_side_gap)
var is_hidden : bool = false

func _ready() -> void:
	get_window().size_changed.connect(_on_window_size_changed)
	if level_props:
		title_label.text = level_props.level_name
		description_label.text = level_props.level_description
	target_position = position.x
	arrow.pivot_offset = Vector2(arrow.get_rect().size.x / 2, arrow.get_rect().size.y / 2)
	custom_minimum_size = Vector2(size.x, 0)
	initial_minimum_size = custom_minimum_size

func _process(_delta: float) -> void:
	if abs(position.x - target_position) > 1: 
		position.x = lerp(position.x, target_position, 0.2) 
	else: 
		position.x = target_position 
		# If the position is close enough to the rigthside gap, we can consider the arrow as pressed and hide the container
		if position.x > get_viewport_rect().size.x - right_side_gap*1.5: 
			arrow.button_pressed = true

func hide_container() -> void:
	target_position = get_viewport_rect().size.x
func show_container() -> void:
	target_position = get_viewport_rect().size.x - size.x

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
