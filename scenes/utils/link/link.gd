class_name Link extends EditableLine2D

@export var origin_connection : ConnectionArea
@export var destination_connection : ConnectionArea
@export var origin_point : Vector2
@export var destination_point : Vector2

@onready var path : Path2D = $Path2D
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu
@onready var start : Area2D = $Start
@onready var end : Area2D = $End

signal updated_path
signal start_connection_changed(origin_connection: ConnectionArea)
signal end_connection_changed(destination_connection: ConnectionArea)

# TODO: Make Path optional (ex: activation links don't need a path)

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

		# Connect the signals
		start.area_entered.connect(func(area): _on_start_area_change(area, false))
		start.area_exited.connect(func(area): _on_start_area_change(area, true))
		end.area_entered.connect(func(area): _on_end_area_change(area, false))
		end.area_exited.connect(func(area): _on_end_area_change(area, true))

		clicked.connect(_on_line_2d_clicked)
		edited_line.connect(update_path.unbind(2))

		update_path()

func _process(delta: float) -> void:
	super(delta)

	# If dragging a start or end point
	if _dragging_point == 0 or _dragging_point == points.size()-1:
		# Update the start and end nodes
		start.position = points[0]
		start.rotation = points[1].angle_to_point(points[0])

		end.position = points[points.size()-1]
		end.rotation = points.get(points.size()-2).angle_to_point(points[points.size()-1])

		if Input.is_action_just_pressed("base_cancel"):
			print("disconecting by pressing cancel")
			if _dragging_point == 0:
					disconnect_start()
			elif _dragging_point == points.size()-1:
					disconnect_end()

func connect_start(connection: ConnectionArea) -> void:
	if connection == destination_connection and connection != null:
		printerr("Cannot connect: start and end cannot be the same ConnectionArea.")
		return
	if not connection.sends:
		printerr(connection.get_parent().name, ": Cannot connect: node is not a sender.")
		return
	origin_connection = connection
	start_connection_changed.emit(origin_connection)

func disconnect_start() -> void:
	origin_connection = null
	start_connection_changed.emit(origin_connection)

func connect_end(connection: ConnectionArea) -> void:
	if connection == origin_connection and connection != null:
		printerr("Cannot connect: start and end cannot be the same ConnectionArea.")
		return
	if not connection.receives:
		printerr(connection.get_parent().name, ": Cannot connect: node is not a receiver.")
		return
	destination_connection = connection
	end_connection_changed.emit(destination_connection)

func disconnect_end() -> void:
	destination_connection = null
	end_connection_changed.emit(destination_connection)


func update_path():
	path.curve = Curve2D.new()
	_update_start()
	_update_end()
	_sync_points()
	updated_path.emit()

func _update_start():
	if points.size() == 0 : return
	if origin_connection == null: return

	if origin_connection.sticks_to_center:
		origin_point = to_local(origin_connection.global_position)
	else :
		origin_point = points[0]
	
	points[0] = origin_point
	start.position = origin_point
	start.rotation = points[1].angle_to_point(origin_point)

func _update_end():
	if points.size() == 0: return 
	if destination_connection == null: return

	if destination_connection.sticks_to_center:
		destination_point = to_local(destination_connection.global_position)
	else :
		destination_point = points[points.size()-1]

	if points.size() == 1:
		add_point(destination_point)
	else: points[points.size()-1] = destination_point
	end.position = destination_point
	end.rotation = points.get(points.size()-2).angle_to_point(destination_point)

func _sync_points():
	path.curve.clear_points()
	for p in points:
		path.curve.add_point(p)

func _on_line_2d_clicked(_event : InputEventMouseButton, _global_position: Vector2, _segment: int, _offset: float) -> void:
	if Input.is_action_just_pressed("object_menu"):
		menu.show_popup()

func _on_start_area_change(start_connection : Area2D, exited : bool) -> void:
	if not start_connection is ConnectionArea: return
	var entered = !exited

	if start_connection == origin_connection:
			if exited:
					disconnect_start()
	elif entered:
			if origin_connection == null:
					connect_start(start_connection)

func _on_end_area_change(end_connection: Area2D, exited : bool) -> void:
	if not end_connection is ConnectionArea: return
	var entered = !exited

	if end_connection == destination_connection:
			if exited:
					disconnect_end()
	elif entered:
			if destination_connection == null:
					connect_end(end_connection)