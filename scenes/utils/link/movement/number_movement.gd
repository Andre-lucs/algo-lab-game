class_name NumberMovement
extends Node

@export var root : Node2D = null
@export var sends : bool = true
@export var receives : bool = true

signal number_received(number : Number)
signal number_sent(number : Number)
signal parent_moved()
signal requesting_move()
signal new_input_path(path : MovementLink)
signal new_output_path(path : MovementLink)

var input_paths : Array[MovementLink] = []
var output_paths : Array[MovementLink] = []

func receive(number : Number):
	if !receives or number == null:
		return false
	if number.is_inside_tree():
		number.reparent(self)
	else :
		add_child(number)
	if receives:
		number_received.emit(number)
		create_tween().tween_property(number, "rotation", 0, 0.2)
		return true
	return false

func send(number : Number):
	if sends and number:
		number_sent.emit(number)
		return true
	return false

# This function is called when the parent node is moved
func update() -> void:
	parent_moved.emit()

func request_send() -> void:
	if output_paths.is_empty():
		return
	if sends:
		requesting_move.emit()
	
func connect_path(path:MovementLink):
	if path.origin_node == self: # C ->
		output_paths.append(path)
		new_output_path.emit(path)
	elif path.destination_node == self: # C <-
		input_paths.append(path)
		new_input_path.emit(path)

func get_input_paths() -> Array[MovementLink]:
	return input_paths

func get_output_paths() -> Array[MovementLink]:
	return output_paths

func _exit_tree() -> void:
	for path in (output_paths+input_paths):
		if !path.is_inside_tree(): continue
		path.queue_free()
	input_paths.clear()
	output_paths.clear()
