extends PanelContainer

var path_scene : PackedScene = preload("res://scenes/objects/builders/path_builder.tscn")
var item_scene : PackedScene = preload("res://scenes/ui/item_preview.tscn")
var activator_link_scene : PackedScene = preload("res://scenes/objects/builders/activation_link_builder.tscn")

@onready var items_container : VBoxContainer = $Items

@export var items : Array[PackedScene] = []

func _ready() -> void:
	items = [NumberContainer.container_scene, path_scene, activator_link_scene]
	for i in range(items.size()):
		var button = Button.new()
		button.keep_pressed_outside = true
		button.action_mode = Button.ActionMode.ACTION_MODE_BUTTON_PRESS
		button.text = items[i].resource_path
		items_container.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(i))

func _on_button_pressed(index : int) -> void:
	print("creating ", items[index].resource_path)
	var item_preview = item_scene.instantiate() as ItemPreview
	item_preview.item = items[index]
	get_tree().root.add_child(item_preview)
