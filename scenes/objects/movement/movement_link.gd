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

		origin_node = origin_connection.number_movement
		destination_node = destination_connection.number_movement
		_origin_parent = origin_node.get_parent()
		_destination_parent = destination_node.get_parent()

		origin_node.number_sent.connect(move_number)
		origin_node.parent_moved.connect(update_path)
		destination_node.parent_moved.connect(update_path)

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
	polygon_colision.polygon = polygon

func _on_object_popup_menu_clicked_option(idx:int) -> void:
	match idx:
		0: # auto
			toggle_auto()
		1:
			delete()

func activate():
	origin_node.request_send()

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


func _on_updated_path() -> void:
	_update_polygon()
