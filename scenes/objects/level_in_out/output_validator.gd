class_name OutputValidator extends Node2D

static var scene : PackedScene = preload("res://scenes/objects/level_in_out/OutputValidator.tscn")

enum State {
	WRONG_NUMBER,
	COMPLETED,
	WAITING_NUMBER,
}

signal received_wrong_number(number: float)
signal received_correct_number(number: float, finished: bool)
signal validation_complete

@export var expected_numbers: Array[float] = []:
	set(value):
		expected_numbers = value.duplicate()
		reset()

@onready var number_display : Label = $RequestedNumber
@onready var sprite : Sprite2D = $Sprite2D
@onready var number_listing: NumberListing = %NumberListing

var next_number_index: int = 0
var state: State = State.WAITING_NUMBER: 
	set(value):
		sprite.frame = value
		state = value

func _ready():
	received_wrong_number.connect(show_warning_message)

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
			validation_complete.emit()
		else:
			sprite.frame = State.COMPLETED
			var tween = create_tween()
			tween.tween_property(sprite, "frame", state, 0.2)
	else:
		received_wrong_number.emit(value)
		state = State.WRONG_NUMBER
	number.queue_free()

func reset() -> void:
	next_number_index = 0
	_update_display()
	state = State.WAITING_NUMBER
	number_listing.numbers = expected_numbers.slice(next_number_index)

func _update_display() -> void:
	if next_number_index < expected_numbers.size():
		number_display.text = str(expected_numbers[next_number_index]).replace(".0", "")
	else:
		number_display.text = ""
		number_display.modulate = Color.TRANSPARENT
		return
	number_listing.numbers = expected_numbers.slice(next_number_index)
	number_listing.update_display()
	number_display.scale = Vector2(0.2, 0.2)
	number_display.create_tween().tween_property(number_display, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)

func show_warning_message(number: float) -> void:
	var warning_message = "Wrong number: " + str(number) + "\nExpected: " + str(expected_numbers[next_number_index])
	Warning.popup(warning_message, global_position - Vector2(0, 100))
