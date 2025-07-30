class_name LevelSetsIndicator extends HBoxContainer

signal selected_level_set(level_set: LevelSet)

@export var level_sets : Array[LevelSet] = []
@export var icons : Array[Texture2D] = []
@export var lock_icon: Texture2D
@export var complete_icon: Texture2D

var current_level_set: LevelSet
var _lock_texture_rect : TextureRect
var _complete_texture_rect : TextureRect

var _layout_ready: bool = false

func _ready() -> void:
	_init_texture_rects()
	_setup_level_sets()

func _process(_delta: float) -> void:
	if not _layout_ready and get_child_count() > 1:
		var first_button = get_child(0) as Button
		if first_button and first_button.size.x > 0:
			_layout_ready = true
			queue_redraw()

func _setup_level_sets() -> void:
	for child in get_children():
		if child is Button:
			child.queue_free()  # Clear existing buttons
	for i in level_sets.size():
		var level_set = level_sets[i]
		var button := Button.new()
		button.icon = icons[i] if i < icons.size() else null
		button.expand_icon = false
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if not button.icon:
			var placeholder_icon := PlaceholderTexture2D.new()
			placeholder_icon.size = Vector2(32, 32)
			button.icon = placeholder_icon

		button.pressed.connect(func():
			select_level_set(level_set, i)
		)

		if level_set.cleared_all_levels():
			button.add_child(_complete_texture_rect.duplicate())
		elif not level_set.can_access():
			button.add_child(_lock_texture_rect.duplicate())
		add_child(button)
	_layout_ready = false

func select_level_set(level_set: LevelSet, idx: int = -1) -> void:
	highlight_button(idx)
	selected_level_set.emit(level_set)

func highlight_button(idx: int) -> void:
	const SCALE := Vector2(1.2, 1.2)
	if idx < 0 or idx >= get_child_count():
		return
	var button := get_child(idx) as Button
	if button:
		button.pivot_offset = button.size / 2
		if is_inside_tree(): 
			button.grab_focus()
		var tween := create_tween()
		tween.tween_property(button, "scale", SCALE, 0.1)
	var other_buttons := get_children().filter(func(child): return child is Button and child != button)
	for other_button in other_buttons:
		if other_button.scale == Vector2.ONE:
			continue # Skip if already scaled
		other_button.pivot_offset = other_button.size / 2
		var other_tween := create_tween()
		other_tween.tween_property(other_button, "scale", Vector2.ONE, 0.1)

func _draw() -> void:
	if not _layout_ready:
		return  # Skip drawing if layout is not ready
	# Draw a dashed line between each pair of adjacent buttons
	var color := Color(1, 1, 1, 0.5)  # Semi-transparent white
	var offset := 10 
	for i in range(get_child_count() - 1):
		var button_a := get_child(i) as Button
		var button_b := get_child(i + 1) as Button
		if not button_a or not button_b:
			continue
		var start_pos := button_a.position + Vector2(button_a.size.x + offset, button_a.size.y / 2)
		var end_pos := button_b.position + Vector2(-offset, button_b.size.y / 2)
		draw_dashed_line(start_pos, end_pos, color, 5, 5, true, true)
	

func _init_texture_rects() -> void:
	_lock_texture_rect = TextureRect.new()
	_lock_texture_rect.texture = lock_icon
	_lock_texture_rect.size = Vector2(32, 32)
	_lock_texture_rect.size_flags_horizontal = SIZE_EXPAND_FILL
	_lock_texture_rect.size_flags_vertical = SIZE_EXPAND_FILL
	_lock_texture_rect.set_anchors_preset(Control.PRESET_CENTER)
	
	_complete_texture_rect = TextureRect.new()
	_complete_texture_rect.texture = complete_icon
	_complete_texture_rect.size = Vector2(32, 32)
	_complete_texture_rect.size_flags_horizontal = SIZE_EXPAND_FILL
	_complete_texture_rect.size_flags_vertical = SIZE_EXPAND_FILL
	_complete_texture_rect.set_anchors_preset(Control.PRESET_CENTER)
