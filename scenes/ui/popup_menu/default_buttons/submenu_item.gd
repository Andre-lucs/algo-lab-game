class_name SubMenuItem extends DefaultMenuItem

var sub_buttons : Array[DefaultMenuItem] = []

@onready var popup : Popup = Popup.new()
@onready var container : Container = HBoxContainer.new()

func _ready() -> void:
	super()
	pressed.disconnect(_custom_callback_handler)

	container.custom_minimum_size = Vector2(32, 32)
	popup.add_child(container)
	popup.hide()
	popup.reset_size()
	add_child(popup)
	pressed.connect(_show_popup_animation)

	for i in frames.size():
		var button := DefaultMenuItem.new()
		var frame := frames[i]
		button.frames.append(frame)
		if i < tooltips.size(): button.tooltips = [tooltips[i]] 
		button.custom_callback = _sub_buttons_callback.bind(i)
		container.add_child(button)
		sub_buttons.append(button)

func _show_popup_animation():
	popup.popup()
	var button_center := get_screen_position()+Vector2(size.x/2, 0)
	var popup_arrangement := Vector2(popup.size.x / 2.0, popup.size.y)
	var gap := Vector2(0, 8)  # Adjust gap as needed
	var target_position = button_center - popup_arrangement - gap
	popup.position = Vector2i(target_position + Vector2(0, size.y) + gap)
	create_tween().tween_property(popup, "position", Vector2i(target_position), 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)

func _hide_popup_animation():
	if popup.is_visible():
		var button_center := get_screen_position()+Vector2(size.x/2, 0)
		var popup_arrangement := Vector2(popup.size.x / 2.0, 0)
		var target_position := Vector2i(button_center - popup_arrangement)
		var tween = create_tween()
		tween.tween_property(popup, "position", target_position, 0.05).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(popup.hide)
		

func _sub_buttons_callback(frame_index: int) -> void:
	if frame_index < 0 or frame_index >= frames.size():
		return
	set_frame(frame_index)
	_hide_popup_animation()
	if custom_callback:
		custom_callback.call()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if container.is_visible():
			popup.hide.call_deferred()
