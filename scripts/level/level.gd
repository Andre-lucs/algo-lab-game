extends Node2D
class_name Level

signal level_completed
signal level_failed

@onready var level_executor : LevelExecutor = $LevelExecutor
@onready var level_info : LevelInfo = %LevelInfo
@onready var toolbox: ObjectToolBox = %Toolbox

@export var level_props : LevelPropsResource = null
@export var level_input_nodes : Array[LevelInput] = []
@export var level_output_nodes : Array[OutputValidator] = []
var validators_finished : int = 0

func _ready() -> void:
	if level_props == null:
		print("LevelPropsResource is not set on level.")
		return

	level_info.level_props = level_props
	if level_props.available_objects:
		print("setting custom avaliable objects to: ", level_props.available_objects)
		toolbox.items = level_props.available_objects

	if level_input_nodes.size() == 0 or level_output_nodes.size() == 0:
		print("No input or output nodes set for the level.")
		return
	
	init_inputs()
	init_validators()

func init_inputs() -> void:
	for i in range(level_props.inputs.size()):
		var input := level_props.inputs[i]
		var node := level_input_nodes[i]
		var numbers : Array[float] = []
		for n in input:
			numbers.append(float(n))  # Ensure numbers are floats
		node.numbers = numbers
	
func init_validators() -> void:
	for i in range(level_props.outputs.size()):
		var level_output = level_props.outputs[i]
		var o := level_output_nodes[i]
		var numbers : Array[float] = []
		for n in level_output:
			numbers.append(float(n))  # Ensure numbers are floats
		o.expected_numbers = numbers
		
		o.received_wrong_number.connect(func(num) : on_number_received(num, false, false))
		o.received_correct_number.connect(func(num, finished) : on_number_received(num, true, finished))

func on_number_received(number: int, correct: bool, finished: bool) -> void:
	if not level_executor.execution_in_progress:
		return  # Evita processamento se a execução já foi encerrada
	
	if not correct:
		level_failed.emit()
		return
	
	if finished:
		print("Validator finished!")
		validators_finished += 1
	
	if validators_finished == level_props.outputs.size():
		level_completed.emit()

func _on_level_failed() -> void:
	print("Level failed!")
	level_executor.finish_execution(false)
	validators_finished = 0

func _on_level_completed() -> void:
	print("Level completed!")
	level_executor.finish_execution(true)
	$AnimationPlayer.play("level_complete")


func _go_to_next_level() -> void:
	if not level_props.next_level:
		get_tree().change_scene_to_file("res://scenes/ui/screens/start_menu.tscn")
		return
	LevelManager.load_level(level_props.next_level)
