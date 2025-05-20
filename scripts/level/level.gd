extends Node2D
class_name Level

signal level_completed
signal level_failed

@onready var level_executor : LevelExecutor = $LevelExecutor
@export var level_title_label : RichTextLabel
@export var level_description_label : RichTextLabel 

@export var level_props : LevelPropsResource = null
var validators_finished : int = 0

func _ready() -> void:
	if level_props == null:
		print("LevelPropsResource is not set on level.")
		return

	print("Level Name: ", level_props.level_name)
	level_title_label.text = level_props.level_name
	print("Level Description: ", level_props.level_description)
	level_description_label.text = level_props.level_description

	spawn_inputs()
	spawn_validators()

func spawn_inputs() -> void:
	var used_count = use_existing_input_containers()	
	var y_input_position = get_viewport_rect().size.y / (level_props.inputs.size()+1)
	var i = 1
	for idx in range(used_count, level_props.inputs.size()): #creates new containers for the rest of the inputs if needded
		var input = level_props.inputs[idx]
		var container := NumberContainer.get_input_container()
		# var number := Number.get_number(input[0]) # depois atualizar para containers com multiplos numeros
		container.default_number = input[0]
		# container.call_deferred("store_number", number)
		container.position = Vector2(100, y_input_position * i)
		i += 1
		add_child(container)

func use_existing_input_containers() -> int:
	var existent_inputs : Array = get_tree().get_nodes_in_group("input_containers").filter(func(node): return node is NumberContainer)
	var used_count = 0
	for con in existent_inputs:
		var container : NumberContainer = con
		if used_count >= level_props.inputs.size():
			break
		var inputArray : Array[int] =  []
		for i in level_props.inputs[used_count]:
			inputArray.append(i)
		container.default_numbers = inputArray
		container._store_default_numbers()
		used_count += 1
	return used_count

func spawn_validators() -> void:
	var y_input_position = get_viewport_rect().size.y / (level_props.inputs.size()+1)
	var i = 1
	for input in level_props.outputs:
		var container := ValidatorContainer.get_instance()
		container.expected_numbers = input
		var level_width = get_viewport_rect().size.x
		container.position = Vector2(level_width -100, y_input_position * i)
		i += 1
		add_child(container)
		container.number_received.connect(on_number_received)

func on_number_received(number: int, correct: bool, finished: bool) -> void:
	if not level_executor.execution_in_progress:
		return  # Evita processamento se a execução já foi encerrada
	
	if not correct:
		print("Incorrect number received: ", number)
		level_executor.finish_execution(false)
		get_tree().set_deferred("paused", true)
		level_failed.emit()
		return
	
	print("Correct number received: ", number)
	
	if finished:
		print("Validator finished!")
		validators_finished += 1
	
	if validators_finished == level_props.outputs.size():
		print("Level completed!")
		level_completed.emit()
		level_executor.finish_execution(true)
		get_tree().set_deferred("paused", true)
