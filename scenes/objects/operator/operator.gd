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

func _on_number_1_received(number: Number) -> void:
	if number_1:
		number_1.queue_free()
	number_1 = number
	number_1.reparent(number_1_conn)
	var tween = number_1.create_tween()
	tween.parallel().tween_property(number_1, "position", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(number_1, "rotation", 0, 0.2)
	tween.play()
	if number_2:
		ready_for_result.emit()

func _on_number_2_received(number: Number) -> void:
	if number_2:
		number_2.queue_free()
	number_2 = number
	number_2.reparent(number_2_conn)
	var tween = number_2.create_tween()
	tween.parallel().tween_property(number_2, "position", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(number_2, "rotation", 0, 0.2)
	tween.play()
	if number_1:
		ready_for_result.emit()

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
	var menu_item : ObjectPopupMenuItem = menu.items[0]
	var menu_item_button : TextureButton = menu.hbox.get_child(0) as TextureButton
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


func _on_menu_clicked_option(idx: int) -> void:
	match idx:
		0:
			operator_type = menu.items[0].current_frame as OperatorType
		1:
			delete()
		_:
			print("Unknown option clicked")

func delete() -> void:
	if number_1:
		number_1.queue_free()
	if number_2:
		number_2.queue_free()
	queue_free()
