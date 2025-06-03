class_name BaseLinkBuilder
extends Area2D

var origin_node: ConnectionArea
var origin_click_position: Vector2

var destination_node: ConnectionArea
var destination_click_position: Vector2

@export var layer: int = 3

func _ready() -> void:
	_highlight_out()

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

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
					_highlight_in()
					break
			elif origin_node != area: # Se o Builder já tiver um origin_node, não pode ser o mesmo
				if try_set_destination(area):
					build_object()
					break
	if Input.is_action_just_released("base_cancel"):
		queue_free()  # Remove o Builder se o botão direito do mouse for pressionado

func _highlight_in() -> void:
	assert(false, "Abstract method _highlight_in() must be implemented in a subclass of BaseLinkBuilder.")
func _highlight_out() -> void:
	assert(false, "Abstract method _highlight_out() must be implemented in a subclass of BaseLinkBuilder.")

func build_object() -> void:
	# override this method in the derived class
	assert(false, "Abstract method build_object() must be implemented in a subclass of BaseLinkBuilder.")
	pass
