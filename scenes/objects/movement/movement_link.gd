extends Link
class_name MovementLink

@export var origin_node : NumberMovement
@export var destination_node : NumberMovement
## Speed of the number moving along the path in **px/s**
@export var speed : float = 150.0

@onready var activatable : Activatable = $Activatable
@onready var polygon_colision : CollisionPolygon2D = $ConnectionArea/CollisionPolygon2D

var items : Array[PathFollow2D] = []
var _origin_parent : Node2D
var _destination_parent : Node2D

signal start_moving(number : Number)
signal end_moving(number : Number)

func _ready() -> void:
		super()
		if origin_connection.number_movement == null or destination_connection.number_movement == null:
			printerr("Origin or destination_node is not linked to a NumberMovement.")
			delete()
			return

		_connect_origin_node(origin_connection)
		_connect_destination_node(destination_connection)

		update_path()

func _process(delta: float) -> void:
		super(delta)
		if items.size() : _animate_moving_numbers(delta)

func move_number(number : Number):
	if number == null:
		return
	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	path.add_child(path_follow)
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

func _update_polygon():
	# Update the collision polygon to match the path
	var polygon = bake_polygon()
	polygon_colision.set_deferred("polygon", polygon) # polygon_colision.polygon = polygon

func _on_object_popup_menu_clicked_option(idx:int) -> void:
	match idx:
		0: # auto
			toggle_auto()
		1:
			delete()

func activate():
	print("origin node: ",origin_node)
	origin_node.request_send()

func toggle_auto():
	activatable.auto = !activatable.auto

func delete() -> void:
	_disconnect_origin_node()
	_disconnect_destination_node()
	queue_free()


func _on_updated_path() -> void:
	_update_polygon()

func _on_start_connection_changed(new_origin: ConnectionArea) -> void:
	if new_origin == null:
			_disconnect_origin_node()
	else:
			_connect_origin_node(new_origin)

func _on_end_connection_changed(new_destination: ConnectionArea) -> void:
	if new_destination == null:
			_disconnect_destination_node()
	else:
			_connect_destination_node(new_destination)

func _connect_origin_node(connection: ConnectionArea) -> void:
	if origin_node:
			_disconnect_origin_node()
	origin_node = connection.number_movement
	if not origin_node.number_sent.is_connected(move_number):
		origin_node.number_sent.connect(move_number)
	_origin_parent = origin_node.get_parent()

func _disconnect_origin_node() -> void:
	if origin_node:
			if self in origin_node.input_paths:
					origin_node.input_paths.erase(self)
			origin_node = null
			_origin_parent = null

func _connect_destination_node(connection: ConnectionArea) -> void:
	if destination_node:
			_disconnect_destination_node()
	destination_node = connection.number_movement
	_destination_parent = destination_node.get_parent()

func _disconnect_destination_node() -> void:
	if destination_node:
			if self in destination_node.input_paths:
					destination_node.input_paths.erase(self)
			destination_node = null
			_destination_parent = null
