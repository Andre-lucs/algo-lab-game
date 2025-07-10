class_name Operator extends Node2D

enum OperatorType{
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

signal result_is_ready

@export var operator_type : OperatorType = OperatorType.ADD : set = _set_operator_type

@onready var sign_label : Label = %SignLabel
@onready var number_1_conn : ConnectionArea = $Number1Connection
@onready var number_2_conn : ConnectionArea = $Number2Connection
@onready var result_movement : NumberMovement = %ResultMovement
@onready var menu : ObjectPopupMenu = %ObjectPopupMenu

var number_1 : Number:
	set(value):
		if value == null:
			if number_1: number_1.queue_free()
			number_1_conn.number_movement.input_locked = false
		else:
			number_1_conn.number_movement.input_locked = true
		number_1 = value
var number_2 : Number:
	set(value):
		if value == null:
			if number_2: number_2.queue_free()
			number_2_conn.number_movement.input_locked = false
		else:
			number_2_conn.number_movement.input_locked = true
		number_2 = value
var result_num : Number

func _ready() -> void:
	# If set trough inspector, set the operator type for the menu
	(menu.custom_items.front() as ObjectPopupMenuItem).initial_frame = operator_type
	_update_sign_label()

func _on_number_1_received(number: Number) -> void:
	number_1 = number
	_setup_number_position(number_1, %Num1Parent)

func _on_number_2_received(number: Number) -> void:
	number_2 = number
	_setup_number_position(number_2, %Num2Parent)

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
				Warning.popup("Cannont divide by zero", global_position - Vector2(0, 100))
				LevelManager.current_level_instance.fail_level()
				return null
	return Number.get_number(result)

func _make_operation() -> void:
	if number_1 == null or number_2 == null:
		print("Numbers not set")
		return
	$AnimationPlayer.play("result_animation")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("RESET")
	
	var result := _get_result_number()
	if result == null:
		print("Result is null")
		return
	if result_num:
		result_num.queue_free()
	result_num = result
	result_num.move_to(Vector2.ZERO, self)
	result_num.scale = Vector2.ZERO
	await result_num.create_tween().tween_property(result_num, "scale", Vector2.ONE, 0.2).finished

	number_1 = null
	number_2 = null
	result_is_ready.emit()
	
func activate() -> void:
	_make_operation()

func send_result(send_requested_number:Callable, copy := false) -> void:
	if result_num:
		var result_num_to_send := result_num if not copy else result_num.duplicate()
		send_requested_number.call(result_num_to_send)
		if not copy: result_num = null

func _set_operator_type(value: OperatorType) -> void:
	operator_type = value
	if not is_inside_tree():
		return
	_update_sign_label()
	
func _update_sign_label() -> void:
	match operator_type:
		OperatorType.ADD:
			sign_label.text = "+"
		OperatorType.SUBTRACT:
			sign_label.text = "-"
		OperatorType.MULTIPLY:
			sign_label.text = "X"
		OperatorType.DIVIDE:
			sign_label.text = "/"


func _on_object_popup_menu_clicked_item(item:DefaultMenuItem, idx:int) -> void:
	match idx:
		0:
			operator_type = item.current_frame as OperatorType

func delete() -> void:
	if number_1:
		number_1.queue_free()
	if number_2:
		number_2.queue_free()
	queue_free()


func _on_reset_requested() -> void:
	if number_1:
		number_1.queue_free()
	if number_2:
		number_2.queue_free()
	number_1 = null
	number_2 = null
	number_1_conn.number_movement.set_deferred("input_locked",false)
	number_2_conn.number_movement.set_deferred("input_locked",false)
	if result_num:
		result_num.queue_free()
		result_num = null
	_update_sign_label()
