extends NumberContainer
class_name ValidatorContainer

static var validator_container_scene : PackedScene = preload("res://scenes/objects/container/validator_container.tscn")

signal number_received(number: int, correct: bool, finished: bool)

@export var expected_numbers: PackedInt32Array = []

@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var received_numbers: Array[int] = []
var stored_wrong_number: bool = false

static func get_instance() -> ValidatorContainer:
	var container = validator_container_scene.instantiate()
	return container

func store_number(number: Number, update_arrange: bool = false):
	
	if received_numbers.size() == expected_numbers.size():
		return # Ignore if already finished
	if stored_wrong_number:
		return # Ignore if already received a wrong number
	
	super(number, update_arrange)

	var value = number.get_value()
	var expected_index = received_numbers.size()

	var is_correct = expected_index < expected_numbers.size() and value == expected_numbers[expected_index]

	if is_correct:
		received_numbers.append(value)
	else:
		stored_wrong_number = true
		received_numbers.append(value)
		number_received.emit(value, false, false)
		return
	var finished = received_numbers.size() == expected_numbers.size()

	number_received.emit(value, is_correct, finished)

func _on_number_received(_number: int, correct: bool, finished: bool):
	if finished:
		state_machine.travel("completed")
	elif correct:
		state_machine.travel("correct_number")
	else:
		state_machine.travel("wrong_number")

func _on_reset_requested() -> void:
	super()
	stored_wrong_number = false
	received_numbers.clear()
