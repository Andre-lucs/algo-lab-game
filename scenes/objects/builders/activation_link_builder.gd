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
	# supondo que seu ActivatorLink (o nó root do link) tenha propriedades para configurar:
	link.origin = origin_node.activatable
	link.destination = destination_node.activatable
	link.origin_point = origin_click_position
	link.destination_point = destination_click_position
	get_tree().current_scene.add_child(link)
	queue_free()
