extends Link
class_name MovementLink

const SIZE_PER_NODE : float = 32.0 # Size of each node in the path

@export var origin_node : NumberMovement
@export var destination_node : NumberMovement
@export var move_duration : float = 1.0 # Duration of the move in seconds

@onready var activatable : Activatable = $Activatable
@onready var polygon_colision : CollisionPolygon2D = $ConnectionArea/CollisionPolygon2D

var path_followers : Array[PathFollow2D] = []
var _origin_parent : Node2D
var _destination_parent : Node2D
var _is_deliver_blocked := false

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
		if activatable.is_paused:
			return
		if path_followers.size() : _animate_moving_numbers(delta)
#region numbermovement
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
	path_followers.append(path_follow)
	start_moving.emit(number)
	print("Moving number: ", number.value)
 
 ## Animate the numbers along the path. ---
 ## This function updates the position of each number along the path based on their progress ratio. ---
 ## If a number reaches the end of the path, it will try to deliver it to the destination node. ---
 ## If the delivery is blocked, it will stop the movement of that number.
func _animate_moving_numbers(delta : float):
	if path_followers.is_empty():
		return
	var path_length := path.curve.get_baked_length()
	var progress_limit 
	var i = 0
	while i < path_followers.size():
		var item = path_followers[i]
		progress_limit = path_length - i * SIZE_PER_NODE
		if _is_deliver_blocked:
			progress_limit -= SIZE_PER_NODE
		item.progress_ratio = min(item.progress_ratio + delta / move_duration, 1.0)
		item.progress = min(item.progress, progress_limit)
		
		# If this follower is at the end, try to deliver
		if item.progress_ratio >= 1.0:
			var delivered = _on_reach_path_end(item)
			if delivered:
				_is_deliver_blocked = false
			else:
				_is_deliver_blocked = true
				var retry_timer = get_tree().create_timer(move_duration/2)
				retry_timer.timeout.connect(func():_is_deliver_blocked = false)
		i+=1
	
func _on_reach_path_end(path_follow : PathFollow2D) -> bool:
	if path_follow.get_child_count() == 0:
		printerr("No child found in PathFollow2D")
		return false
	var child = path_follow.get_children().front()
	if child == null:
		printerr("No child found in PathFollow2D")
		return false
	var number = child as Number
	var successfully_moved = destination_node.receive(number)
	if not successfully_moved:
		return false
	path_followers.erase(path_follow)
	path_follow.queue_free()
	end_moving.emit(number)
	return true
#endregion
func _update_polygon():
	# Update the collision polygon to match the path
	var polygon = bake_polygon()
	polygon_colision.set_deferred("polygon", polygon) # polygon_colision.polygon = polygon

func activate():
	if not destination_node:
		return
	origin_node.request_send()

func delete() -> void:
	_disconnect_origin_node()
	_disconnect_destination_node()
	queue_free()

#region Connections
func _on_start_connection_changed(new_origin: ConnectionArea) -> void:
	if new_origin == null:
			_disconnect_origin_node()
	else:
			if new_origin.number_movement == null:
					printerr("Origin node is not a NumberMovement.")
					disconnect_start()
					return
			_connect_origin_node(new_origin)

func _on_end_connection_changed(new_destination: ConnectionArea) -> void:
	if new_destination == null:
			_disconnect_destination_node()
	else:
			if new_destination.number_movement == null:
					printerr("Destination node is not a NumberMovement.")
					disconnect_end()
					return
			_connect_destination_node(new_destination)

func _connect_origin_node(connection: ConnectionArea) -> void:
	if not connection.number_movement.sends:
			printerr(connection.get_parent().name, ": Cannot connect: node is not a sender.")
			disconnect_start()
			return
	if origin_node:
			_disconnect_origin_node()
	origin_node = connection.number_movement
	if not origin_node.number_sent.is_connected(move_number):
		origin_node.number_sent.connect(move_number)
	_origin_parent = origin_node.root
	if self not in origin_node.output_paths: origin_node.output_paths.append(self)

func _disconnect_origin_node() -> void:
	if origin_node:
			if self in origin_node.output_paths:
					origin_node.output_paths.erase(self)
			origin_node = null
			_origin_parent = null

func _connect_destination_node(connection: ConnectionArea) -> void:
	if not connection.number_movement.receives:
			printerr(connection.get_parent().name, ": Cannot connect: node is not a receiver.")
			disconnect_end()
			return
	if destination_node:
			_disconnect_destination_node()
	destination_node = connection.number_movement
	_destination_parent = destination_node.root
	if self not in destination_node.input_paths: destination_node.input_paths.append(self)

func _disconnect_destination_node() -> void:
	if destination_node:
			if self in destination_node.input_paths:
					destination_node.input_paths.erase(self)
			destination_node = null
			_destination_parent = null
#endregion


func _on_reset_requested() -> void:
	# Reset the path followers and remove them from the scene
	for follower in path_followers:
		follower.queue_free()
	path_followers.clear()
	_is_deliver_blocked = false

func _update_end():
	super()
	if points.size() == 0: return 
	if destination_connection == null: return

	var last_point = points[points.size()-1]
	var penultimate_point = points[points.size()-2]

	var new_last_point = last_point.move_toward(penultimate_point, SIZE_PER_NODE)
	points[points.size()-1] = new_last_point
	end.position = new_last_point


func _on_success_activated() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate", Global.Colors["red"], 0.1)
	t.tween_property(self, "modulate", Global.Colors["white"], 0.2)
	t.play()
