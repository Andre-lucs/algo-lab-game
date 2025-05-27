class_name Operator extends Node2D

enum OperatorType{
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

signal ready_for_result
signal operator_activated(result: Number)

@export var operator_type : OperatorType = OperatorType.ADD : set = _set_operator_type

@onready var sign_label : Label = %SignLabel
@onready var number_1_conn : ConnectionArea = $Number1Connection
@onready var number_2_conn : ConnectionArea = $Number2Connection
@onready var result_movement : NumberMovement = %ResultMovement
@onready var menu : ObjectPopupMenu = %ObjectPopupMenu

var number_1 : Number
var number_2 : Number
var menu_option_index : int = 1

func _on_number_1_received(number: Number) -> void:
	if number_1:
		number_1.queue_free()
	number_1 = number
	_setup_number_position(number_1, number_1_conn)
	if number_2:
		ready_for_result.emit()

func _on_number_2_received(number: Number) -> void:
	if number_2:
		number_2.queue_free()
	number_2 = number
	_setup_number_position(number_2, number_2_conn)
	if number_1:
		ready_for_result.emit()

func _setup_number_position(number: Number, new_parent: Node2D) -> void:
	if number == null:
		return
	if not number.is_inside_tree():
		new_parent.add_child(number)
	else: number.reparent(new_parent)
	
	var tween = number.create_tween()
	tween.parallel().tween_property(number, "position", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(number, "rotation", 0, 0.2)
	tween.play()

func activate() -> void:
	if number_1 == null or number_2 == null:
		print("Numbers not set")
		return
	var result := _get_result_number()
	if result == null:
		print("Result is null")
		return
	result_movement.send(result)
	operator_activated.emit(result)
	number_1.queue_free()
	number_2.queue_free()
	number_1 = null
	number_2 = null

func _get_result_number() -> Number:
	if number_1 == null or number_2 == null:
		return null
	var result : float
	match operator_type:
		OperatorType.ADD:
			result = number_1.get_value() + number_2.get_value()
		OperatorType.SUBTRACT:
			result = number_1.get_value() - number_2.get_value()
		OperatorType.MULTIPLY:
			result = number_1.get_value() * number_2.get_value()
		OperatorType.DIVIDE:
			if number_2.get_value() != 0:
				result = number_1.get_value() / number_2.get_value()
			else:
				print("Division by zero")
				return null
	return Number.get_number(result)

func _set_operator_type(value: OperatorType) -> void:
	operator_type = value
	if not is_inside_tree():
		_update_sign_label.call_deferred()
		return
	_update_sign_label()
	
func _update_sign_label() -> void:
	var menu_item : ObjectPopupMenuItem = menu.items[menu_option_index]
	var menu_item_button : TextureButton = menu.hbox.get_child(menu_option_index) as TextureButton
	menu_item.set_frame(operator_type, menu_item_button)
	match operator_type:
		OperatorType.ADD:
			sign_label.text = "+"
		OperatorType.SUBTRACT:
			sign_label.text = "-"
		OperatorType.MULTIPLY:
			sign_label.text = "X"
		OperatorType.DIVIDE:
			sign_label.text = "/"


func _on_object_popup_menu_clicked_item(item:ObjectPopupMenuItem, idx:int) -> void:
	match idx:
		1:
			operator_type = menu.items[menu_option_index].current_frame as OperatorType

func delete() -> void:
	if number_1:
		number_1.queue_free()
	if number_2:
		number_2.queue_free()
	queue_free()
