class_name Link extends EditableLine2D

@export var origin_connection : ConnectionArea
@export var destination_connection : ConnectionArea

@onready var path : Path2D = $Path2D
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu
@onready var start : Node2D = $Start
@onready var end : Node2D = $End

signal updated_path

func _ready() -> void:
		super()
		if origin_connection == null or destination_connection == null:
			printerr("Origin or destination_node not set")
			return

		add_point(to_local(origin_connection.global_position))
		add_point((destination_connection.global_position))

		clicked.connect(_on_line_2d_clicked)
		edited_line.connect(update_path.unbind(1))

		update_path()

func update_path():
	if path.curve == null:
		path.curve = Curve2D.new()
	_update_start()
	_update_end()
	_sync_points()
	updated_path.emit()

func _update_start():
	if points.size() == 0 or origin_connection == null: return
	points[0] = to_local(origin_connection.global_position)

	var newPos = points[0]
	start.position = newPos
	start.rotation = points[1].angle_to_point(newPos)

func _update_end():
	if points.size() == 0 or destination_connection == null: return
	
	if points.size() == 1:
		add_point(to_local(destination_connection.global_position))
	else: points[points.size()-1] = to_local(destination_connection.global_position)

	var newPos = points[points.size()-1]
	end.position = newPos
	end.rotation = points.get(points.size()-2).angle_to_point(newPos)

func _sync_points():
	path.curve.clear_points()
	for p in points:
		path.curve.add_point(p)

func _on_line_2d_clicked(_event : InputEventMouseButton, _global_position: Vector2, _segment: int, _offset: float) -> void:
	if Input.is_action_just_pressed("object_menu"):
		menu.show_popup()
