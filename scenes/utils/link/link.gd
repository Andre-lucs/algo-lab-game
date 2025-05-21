class_name Link extends EditableLine2D

@export var origin_connection : ConnectionArea
@export var destination_connection : ConnectionArea
@export var origin_point : Vector2
@export var destination_point : Vector2

@onready var path : Path2D = $Path2D
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu
@onready var start : Node2D = $Start
@onready var end : Node2D = $End

signal updated_path

# TODO: Make Path optional (ex: activation links don't need a path)
# TODO: Make link listen to start and end to check if they still overlap a connection area if not give a future warning AND reconect the link moving the point to the connection area

func _ready() -> void:
		super()
		if origin_connection == null or destination_connection == null:
			printerr("Origin or destination_node not set")
			return
		
		if not origin_point:
			origin_point = to_local(origin_connection.global_position)
		if not destination_point:
			destination_point = to_local(destination_connection.global_position)

		add_point(origin_point)
		add_point(destination_point)

		clicked.connect(_on_line_2d_clicked)
		edited_line.connect(update_path.unbind(1))

		update_path()

func update_path():
	path.curve = Curve2D.new()
	_update_start()
	_update_end()
	_sync_points()
	updated_path.emit()

func _update_start():
	if points.size() == 0 or origin_connection == null: return
	points[0] = origin_point

	var newPos = points[0]
	start.position = newPos
	start.rotation = points[1].angle_to_point(newPos)

func _update_end():
	if points.size() == 0 or destination_connection == null: return
	
	if points.size() == 1:
		add_point(destination_point)
	else: points[points.size()-1] = destination_point

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
