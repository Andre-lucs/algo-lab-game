extends BaseLinkBuilder
class_name PathBuilder

var path_scene: PackedScene = preload("res://scenes/utils/link/movement/movement_link.tscn")

func _init() -> void:
	layer = 3

func _highlight_out() -> void:
	_highlight_movement(false, true)
	_highlight_movement()

func _highlight_in() -> void:
	_highlight_movement(true, false)
	_highlight_movement()

func _highlight_movement(_in := true, _out := true) -> void:
	Highlight.highlight_type_compact(HighlightOptions.ObjectType.NUMBER_MOVEMENT, 
																		_in, _out, 
																		Highlight.HighlightLength.SHORT, Global.Colors["white"])

func create_path():
	if path_scene == null:
		printerr("Cannot create path – missing scene.")
		queue_free()
		return
	if origin_node == null or destination_node == null:
		printerr("Cannot create path – origin or destination is missing.")
		queue_free()
		return
	if origin_node.number_movement == null or destination_node.number_movement == null:
		printerr("Cannot create path – origin or destination is not a NumberMovement.")
		queue_free()
		return
	var path := path_scene.instantiate() as MovementLink
	print("Creating path from ", origin_node.name, " to ", destination_node.name)
	origin_node.number_movement.connect_path(path)
	path.origin_connection = origin_node
	path.destination_connection = destination_node
	get_tree().current_scene.add_child(path)
	queue_free()  # Remove o PathBuilder depois de criar o path

func build_object() -> void:
	create_path()
