class_name ObjectToolBox extends PanelContainer

@export var preview_scene : PackedScene

@onready var items_container : BoxContainer = $Items
@onready var base_button : Button = $BaseButton

@export var items : Array[ToolBoxItem] = []:
	set(value):
		items = value
		_update_items_ui()

func _ready() -> void:
	base_button.hide()
	_update_items_ui.call_deferred()

func _on_button_pressed(index : int) -> void:
	print("creating ", items[index].resource_path)
	get_tree().root.add_child(create_item_preview(items[index]))

func create_item_preview(item : ToolBoxItem) -> ItemPreview:
	var item_preview = preview_scene.instantiate() as ItemPreview
	item_preview.item = item.target_scene
	item_preview.preview_image = item.preview_image
	item_preview.custom_args = item.custom_args
	return item_preview

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
		button.pressed.connect(_on_button_pressed.bind(i))

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