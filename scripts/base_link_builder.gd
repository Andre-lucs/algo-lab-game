class_name BaseLinkBuilder
extends Area2D

var origin_node: ConnectionArea
var origin_click_position: Vector2

var destination_node: ConnectionArea
var destination_click_position: Vector2

@export var layer: int = 3

func _ready() -> void:
	highlight_on_layer() # Highlight the number 

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func highlight_on_layer(area2d_layer : int = layer, sender : bool = true):
	var method = "highlight_sender" if sender else "highlight_receiver"
	get_tree().call_group("connections", method, area2d_layer)

func try_set_origin(candidate: ConnectionArea) -> bool:
	if origin_node != null:
		return false

	var connection := candidate
	if connection and connection.sends:
		origin_node = candidate
		origin_click_position = get_global_mouse_position()	
		print("Origin set.")
		return true
	
	return false

func try_set_destination(candidate: ConnectionArea) -> bool:
	if destination_node != null or origin_node == null:
		return false

	var connection := candidate
	if connection and connection.receives:
		destination_node = candidate
		destination_click_position = get_global_mouse_position()
		print("Destination set.")
		return true
	
	return false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("base_accept"):
		for area in get_overlapping_areas():
			if not area is ConnectionArea: continue
			
			if origin_node == null:
				if try_set_origin(area):
					highlight_on_layer(layer, false)  # highlight os receivers
					break
			elif origin_node != area: # Se o Builder já tiver um origin_node, não pode ser o mesmo
				if try_set_destination(area):
					build_object()
					break
	if Input.is_action_just_released("base_cancel"):
		queue_free()  # Remove o Builder se o botão direito do mouse for pressionado

func build_object() -> void:
	# override this method in the derived class
	assert(false, "build_object() not implemented in BaseLinkBuilder")
	pass
