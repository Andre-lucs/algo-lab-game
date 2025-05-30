class_name ControllableCamera2D extends Camera2D

@export var listen_to_input : bool = true
@export_group("Drag")
@export var drag_action : StringName = "drag_camera"
## Speed in px/s
@export var drag_speed : float = 150
@export var position_smooth := 10
@export_group("Zoom")
@export var zoom_in_action : StringName = "zoom_in"
@export var zoom_out_action : StringName = "zoom_out"
@export var zoom_speed : float = 0.2
@export var min_zoom : float = .7
@export var max_zoom : float = 2.5

var dragging : bool = false

func _init() -> void:
	if position_smooth:
		position_smoothing_enabled = true
		position_smoothing_speed = position_smooth

func _input(event: InputEvent) -> void:
	if not listen_to_input:
		return
	_handle_drag(event)
	_handle_zoom(event)

func _handle_drag(event:InputEvent) -> void:
	if event.is_action(drag_action):
		if event.is_pressed():
			dragging = true
		else:
			dragging = false
	
	if dragging and event is InputEventMouseMotion:
		var motion_event := event as InputEventMouseMotion
		var delta := motion_event.relative
		var speed = delta * drag_speed * get_process_delta_time()
		position = get_screen_center_position() - speed

func _handle_zoom(event: InputEvent) -> void:
	if event.is_action(zoom_in_action) and zoom.x < max_zoom:
		create_tween().tween_property(self, "zoom", _clamped_zoom(zoom.x * (1.0 + zoom_speed)), 0.2)
	elif event.is_action(zoom_out_action) and zoom.x > min_zoom:
		create_tween().tween_property(self, "zoom", _clamped_zoom(zoom.x * (1.0 - zoom_speed)), 0.2)

func _clamped_zoom(value : float) -> Vector2:
	# Returns the clamped zoom value
	return Vector2(clamp(value, min_zoom, max_zoom), clamp(value, min_zoom, max_zoom))
