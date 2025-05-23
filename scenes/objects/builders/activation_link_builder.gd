extends BaseLinkBuilder
class_name ActivationLinkBuilder

var activation_link_scene: PackedScene = preload("res://scenes/objects/activation/activator_link.tscn")

func _init() -> void:
	layer = 4

func build_object() -> void:
	if origin_node == null or destination_node == null:
		printerr("Cannot build activation link – missing endpoints.")
		queue_free()
		return

	var link := activation_link_scene.instantiate() as ActivatorLink
	link.origin_connection = origin_node
	link.destination_connection = destination_node
	link.origin_point = origin_click_position
	link.destination_point = destination_click_position
	get_tree().current_scene.add_child(link)
	queue_free()
