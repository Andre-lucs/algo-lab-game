class_name OutputValidator extends Node2D

enum State {
	WRONG_NUMBER,
	COMPLETED,
	WAITING_NUMBER,
}

signal received_wrong_number(number: float)
signal received_correct_number(number: float, finished: bool)

@export var expected_numbers: Array[float] = []

@onready var number_display : Label = $RequestedNumber
@onready var sprite : Sprite2D = $Sprite2D

var next_number_index: int = 0
var state: State = State.WAITING_NUMBER: 
	set(value):
		sprite.frame = value
		state = value

func check_number(number:Number) -> void:
	if next_number_index >= expected_numbers.size():
		return
	var value := number.get_value()
	var expected_value := expected_numbers[next_number_index] 
	if value == expected_value:
		next_number_index += 1
		_update_display()
		var finished := next_number_index >= expected_numbers.size()
		received_correct_number.emit(value, finished)
		if finished:
			state = State.COMPLETED
		else:
			sprite.frame = State.COMPLETED
			var tween = create_tween()
			tween.tween_property(sprite, "frame", state, 0.2)
	else:
		received_wrong_number.emit(value)
		state = State.WRONG_NUMBER

func reset() -> void:
	next_number_index = 0
	_update_display()
	state = State.WAITING_NUMBER

func _update_display() -> void:
	if next_number_index < expected_numbers.size():
		number_display.text = str(expected_numbers[next_number_index]).replace(".0", "")
	else:
		number_display.text = ""
		number_display.modulate = Color.TRANSPARENT
		return
	number_display.modulate = Color.WHITE
	number_display.scale = Vector2(0.2, 0.2)
	var anim = number_display.create_tween().set_parallel(true)
	anim.tween_property(number_display, "modulate", Color.WHITE, 0.2).set_ease(Tween.EASE_IN_OUT)
	anim.tween_property(number_display, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	anim.play()
