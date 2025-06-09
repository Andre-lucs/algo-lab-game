class_name LevelInput extends Node2D

static var scene : PackedScene = preload("res://scenes/objects/level_in_out/LevelInput.tscn")

## Emmited when there are no more numbers to move
signal empty 

@export var numbers: Array[float] = []:
	set(value):
		numbers = value.duplicate()
		reset()

@onready var num_move : NumberMovement = $NumberMovement
@onready var next_number_display: Label = $NextNumber
@onready var number_listing: NumberListing = %NumberListing

var numbers_to_move: Array[float]

func _ready() -> void:
	reset()

func reset() -> void:
	numbers_to_move = numbers.duplicate()
	number_listing.numbers = numbers_to_move
	_update_last_number_display()

func _update_last_number_display() -> void:
	if not numbers_to_move.is_empty():
		next_number_display.text = str(numbers_to_move.front()).replace(".0", "")
		next_number_display.modulate = Color.TRANSPARENT
		next_number_display.create_tween().tween_property(
			next_number_display, "modulate", Color.WHITE, 0.2
		).set_ease(Tween.EASE_IN_OUT)
	else:
		next_number_display.text = ""

func _get_number_to_move(remove_number := true) -> Number:
	if numbers_to_move.is_empty():
		return null
	var number := numbers_to_move.front() as Number
	if remove_number:
		numbers_to_move.pop_front()
		if numbers_to_move.is_empty():
			empty.emit()
	_update_last_number_display()
	number_listing.update_display()
	return number

func _on_number_movement_requesting_move(send_requested_number:Callable) -> void:
	var number := _get_number_to_move()
	if number:
		send_requested_number.call(number)

func _on_number_movement_requesting_copy(send_requested_number:Callable) -> void:
	var number := _get_number_to_move(false)
	if number:
		send_requested_number.call(number.duplicate())
