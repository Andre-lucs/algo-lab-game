class_name ObjectToolBox extends PanelContainer

@export var preview_scene : PackedScene

@onready var items_container : BoxContainer = $Items
@onready var base_button : Button = $BaseButton

@export var items : Array[ToolBoxItem] = []:
	set(value):
		items = value
		_update_items_ui()

var _creating_item_index := -1
var _mouse_over := false

func _ready() -> void:
	base_button.hide()
	_update_items_ui.call_deferred()

func _on_button_up(index : int) -> void:
	if _creating_item_index == -1:
		return
	
	var item = items[_creating_item_index]
	if not item.use_item_preview:
		create_direct_instance(item)
		_creating_item_index = -1

func _on_button_down(index : int) -> void:
	_creating_item_index = index

func _on_mouse_entered() -> void:
	_mouse_over = true
	var item_previews = get_tree().get_nodes_in_group("item_preview")
	for preview in item_previews:
		if preview is ItemPreview:
			preview.queue_free()  # Remove existing item previews when mouse re-enters the toolbox

# Create the item preview in the correct mode
func _on_mouse_exited() -> void:
	_mouse_over = false
	if _creating_item_index >= 0:
		var item := items[_creating_item_index]
		if item.use_item_preview:
			create_item_preview(item)
		else:
			create_direct_instance(item)
		_creating_item_index = -1

func _gui_input(event: InputEvent) -> void:
	if not _mouse_over:
		return
	# Stop creating item when clicking right button
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT: 
		_creating_item_index = -1

func create_item_preview(item : ToolBoxItem) -> void:
	var item_preview = preview_scene.instantiate() as ItemPreview
	item_preview.item = item.target_scene
	item_preview.preview_image = item.preview_image
	item_preview.custom_args = item.custom_args
	get_tree().current_scene.add_child(item_preview)
	item_preview.global_position = get_global_mouse_position()

func create_direct_instance(item: ToolBoxItem) -> void:
	var item_instance = item.target_scene.instantiate()
	if item.custom_args:
		for key in item.custom_args.keys():
			item_instance.set(key, item.custom_args[key])
	get_tree().current_scene.add_child(item_instance)
	item_instance.global_position = get_global_mouse_position()

func _update_items_ui():
	if not is_inside_tree():
		return
	for child in items_container.get_children():
		child.queue_free()
	for i in range(items.size()):
		var button = base_button.duplicate() as Button
		button.icon = items[i].icon
		button.tooltip_text = items[i].item_name
		button.show()
		items_container.add_child(button)
		button.button_up.connect(_on_button_up.bind(i))
		button.button_down.connect(_on_button_down.bind(i))

func slide_down(amount_by_height := 1.0):
	create_tween().tween_property(self, "position:y", position.y + get_rect().size.y * amount_by_height, 0.2)
func slide_up(amount_by_height := 1.0):
	create_tween().tween_property(self, "position:y", position.y - get_rect().size.y * amount_by_height, 0.2)

func disable_input():
	for child in items_container.get_children():
		if child is Button:
			child.disabled = true
func enable_input():
	for child in items_container.get_children():
		if child is Button:
			child.disabled = false
