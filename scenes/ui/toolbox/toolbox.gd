@tool
extends PanelContainer

@export var preview_scene : PackedScene : 
	set(v):
		preview_scene = v
		update_configuration_warnings()

@onready var items_container : VBoxContainer = $Items

@export var items : Array[PackedScene] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if _get_configuration_warnings().size() > 0:
		printerr("Toolbox configuration warnings: ", _get_configuration_warnings())
		return
	for i in range(items.size()):
		var button = Button.new()
		button.keep_pressed_outside = true
		button.action_mode = Button.ActionMode.ACTION_MODE_BUTTON_PRESS
		button.text = items[i].resource_path
		items_container.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(i))

func _on_button_pressed(index : int) -> void:
	print("creating ", items[index].resource_path)
	var item_preview = preview_scene.instantiate() as ItemPreview
	item_preview.item = items[index]
	get_tree().root.add_child(item_preview)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if preview_scene == null:
		warnings.append("Item preview scene is not set.")
	
	return warnings