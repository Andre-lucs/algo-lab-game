extends Path2D
class_name Path

@export var origin_node : NumberMovement
@export var destination_node : NumberMovement
## Speed of the number moving along the path in **px/s**
@export var speed : float = 1.0

@onready var line :ClickableLine2D = $Line2D
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu
@onready var activatable : Activatable = $Activatable
@onready var polygon_colision : CollisionPolygon2D = $ConnectionArea/CollisionPolygon2D

var items : Array[PathFollow2D] = []
var points : Array[Vector2] = []
var _origin_parent : Node2D
var _destination_parent : Node2D

signal start_moving(number : Number)
signal end_moving(number : Number)

func _ready() -> void:
		if origin_node == null or destination_node == null:
			printerr("Origin or destination_node not set")
			return
		
		_origin_parent = origin_node.get_parent()
		_destination_parent = destination_node.get_parent()

		points.append(_origin_parent.position)
		points.append(_destination_parent.position)

		origin_node.number_sent.connect(move_number)
		origin_node.parent_moved.connect(update_path)
		destination_node.parent_moved.connect(update_path)

		update_path()

func _process(delta: float) -> void:
		if items.size() : _animate_moving_numbers(delta)

func move_number(number : Number):
	if number == null:
		return
	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	add_child(path_follow)
	if number.is_inside_tree():
		number.reparent(path_follow)
	else:
		path_follow.add_child(number)
	number.position = Vector2.ZERO
	items.append(path_follow)
	start_moving.emit(number)
	print("Moving number: ", number.value)

func _animate_moving_numbers(delta : float):
	for item in items:
		item.progress += delta * speed
		if item.progress_ratio >= 1:
			# Remove the item from the array if it has reached the end
			items.erase(item)
			_on_reach_path_end(item)
	
func _on_reach_path_end(path_follow : PathFollow2D):
	if path_follow.get_child_count() == 0:
		printerr("No child found in PathFollow2D")
		return
	var child = path_follow.get_children().front()
	if child == null:
		printerr("No child found in PathFollow2D")
		return
	var number = child as Number
	destination_node.receive(number)
	path_follow.queue_free()
	# Emit a signal or call a function to indicate the number has reached its destination_node
	end_moving.emit(number)

func update_path():
	if curve == null:
		curve = Curve2D.new()
	_update_start()
	_update_end()
	_sync_points()
	_update_polygon()

func _update_start():
	if points.size() == 0: return
	points[0] = _origin_parent.position

func _update_end():
	if points.size() == 0: return
	points[points.size()-1] = _destination_parent.position
	var newPos = points[points.size()-1]
	$Arrow.position = newPos
	$Arrow.rotation = points.front().angle_to_point(newPos)

func _update_polygon():
	# Update the collision polygon to match the path
	var polygon = line.bake_polygon()
	polygon_colision.polygon = polygon

func _sync_points():
	line.clear_points()
	curve.clear_points()
	for p in points:
		line.add_point(p)
		curve.add_point(p)

func _on_line_2d_clicked(event : InputEventMouseButton, _global_position: Vector2, _segment: int, _offset: float) -> void:
	if event.is_action_pressed("object_menu"):
		menu.show_popup()

func activate():
	origin_node.request_send()

func _on_object_popup_menu_clicked_option(idx:int) -> void:
	match idx:
		0: # auto
			toggle_auto()
		1:
			delete()

func toggle_auto():
	activatable.auto = !activatable.auto

func delete() -> void:
	origin_node.output_paths.erase(self)
	origin_node.connected_paths.erase(self)
	destination_node.input_paths.erase(self)
	origin_node.number_sent.disconnect(move_number)
	origin_node.parent_moved.disconnect(update_path)
	destination_node.parent_moved.disconnect(update_path)
	queue_free()
