class_name NumberListing
extends Control

const SEPARATION := 10

@export var mouse_area : MouseInteractionArea2D
@export var show_on_hover := true
@export var time_hovering := 1.0

@onready var base_num_label: Label = %BaseNumLabel
@onready var numbers_container: HBoxContainer = $HBoxContainer

var _required_width : float
var numbers : Array[float]

func _ready() -> void:
	if not show_on_hover: return
	if not mouse_area:
		push_error("Show on hover is true but no MouseInteractionArea is set")
		return
	mouse_area.mouse_entered.connect(_on_mouse_entered)
	mouse_area.mouse_exited.connect(_on_mouse_exited)

func display():
	_required_width = 0
	for c in numbers_container.get_children():
		c.free()
	if numbers.is_empty():
		return
	for n in numbers:
		var label := base_num_label.duplicate() as Label
		label.text = str(n).replace(".0", "").replace(",0", "")
		_required_width += label.text.length() * base_num_label.label_settings.font_size + SEPARATION
		numbers_container.add_child(label)
		numbers_container.add_child(VSeparator.new())
		label.show()
	var last_sep = numbers_container.get_children().pop_back()
	if last_sep: last_sep.queue_free()
	show()

func get_required_width() -> float:
	return _required_width;

func update_display():
	if visible:
		display()
		if numbers.is_empty():
			hide()

func _on_mouse_entered() -> void:
	await get_tree().create_timer(time_hovering).timeout
	if not mouse_area.mouse_over:return
	display()

func _on_mouse_exited() -> void:
	hide()
