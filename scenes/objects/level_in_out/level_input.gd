class_name LevelInput extends Node2D

@export var numbers: Array[float] = []

@onready var num_move : NumberMovement = $NumberMovement
@onready var next_number_display: Label = $NextNumber

var numbers_to_move: Array[float]

func _ready() -> void:
	reset()

func move_number(copy := false) -> void:
	if numbers_to_move.is_empty():
		return
	var number := Number.get_number(numbers_to_move.pop_back()) if copy else Number.get_number(numbers_to_move.back())
	num_move.send(number)
	_update_last_number_display()

func reset() -> void:
	numbers_to_move = numbers.duplicate()
	_update_last_number_display()

func _update_last_number_display() -> void:
	if not numbers_to_move.is_empty():
		next_number_display.text = str(numbers_to_move.back()).replace(".0", "")
		next_number_display.modulate = Color.TRANSPARENT
		next_number_display.create_tween().tween_property(
			next_number_display, "modulate", Color.WHITE, 0.2
		).set_ease(Tween.EASE_IN_OUT)
	else:
		next_number_display.text = ""