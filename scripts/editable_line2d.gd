class_name EditableLine2D extends ClickableLine2D

signal edited_line(line :EditableLine2D, point_idx : int)

@export var enable_editing : bool = true

@export var point_color : Color = Color(0, 1, 0, 0.5)
@export var point_color_edit : Color = Color(1, 0, 0, 1)
@export var point_radius : float = 4.0
@export var point_radius_edit : float = 8.0

@export var edit_on_action : String = "object_grab";

var _dragging_point := -1:
	set(value):
		_dragging_point = value
		if value == -1:
			_grabbable.invalidate_grab()
		
var _grabbable : Grabbable = null

func _ready() -> void:
	if edit_on_action not in actions: actions.append(edit_on_action)
	clicked.connect(_edit_on_click)
	released.connect(_edit_on_release)

	_grabbable = Grabbable.new()
	_grabbable.grab_priority = Grabbable.GrabPriority.HIGH
	_grabbable.grab_speed = Grabbable.GrabbingSpeed.FAST
	add_child(_grabbable)

func _edit_on_click(event : InputEventMouseButton, global_position: Vector2, segment: int, offset: float) -> void:
	if enable_editing == false: return
	if not Input.is_action_just_pressed(edit_on_action):
		return
	
	if _grabbable.validate_dragging(true):
		# If a grabbable is being dragged, we don't allow editing
		return	
	_grabbable.active = true

	await get_tree().process_frame
	if not _grabbable.filter_grabbing_by_priority():
		# If this grabbable is not the highest priority, stop dragging
		return
	prints("Path: ", get_path(),"; EditableLine2D: _edit_on_click called with segment:", segment, "at position:", global_position)
	# Find the closest point to the click
	var min_dist := 16.0 # Adjust this threshold as needed
	var closest_idx := -1
	var local_position = to_local(global_position)
	for i in range(points.size()):
		var dist = local_position.distance_squared_to(points[i])
		if dist < (min_dist * min_dist): # Use squared distance for performance
			min_dist = dist
			closest_idx = i
	if closest_idx != -1:
		_dragging_point = closest_idx
	else:
		add_point(local_position, segment+1)
		_dragging_point = segment+1
		

func _edit_on_release(event : InputEventMouseButton, inline: bool, global_position: Vector2, segment: int, offset: float) -> void:
	if enable_editing == false: return
	if not event.is_action(edit_on_action):
		return
	if _dragging_point == -1: # No point was selected or point was deleted
		return
	edited_line.emit(self, _dragging_point)
	_dragging_point = -1
	queue_redraw()

func _process(_delta):
	if _dragging_point != -1:
		# Move the selected point to the mouse position (converted to local)
		points[_dragging_point] = to_local(get_global_mouse_position())
		# If pressing base_cancel while dragging, delete the point
		if Input.is_action_just_pressed("base_cancel"):
			if points.size() > 2:
				remove_point(_dragging_point)
				edited_line.emit(self, _dragging_point)
				_dragging_point = -1
				queue_redraw()

func _draw() -> void:
		for i in range(points.size()):
			if i == _dragging_point:
				draw_circle(points[i], point_radius_edit, point_color_edit)
			else:	
				draw_circle(points[i], point_radius, point_color)
