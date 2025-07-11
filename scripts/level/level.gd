extends Node2D
class_name Level

signal level_completed
signal level_failed

const ObjectsDescription = preload("uid://dsighljguajpa")

@export var GENERATED_NODES_SPACING := 200.0

@onready var level_executor : LevelExecutor = $LevelExecutor
@onready var level_info : LevelInfo = %LevelInfo
@onready var toolbox: ObjectToolBox = %Toolbox
@onready var level_limits : ReferenceRect = $LevelLimits
@onready var camera : ControllableCamera2D = $ControllableCamera2D

@export var level_props : LevelPropsResource = null
@export var level_input_nodes : Array[LevelInput] = []
@export var level_output_nodes : Array[OutputValidator] = []
var validators_finished : int = 0

var _default_objects : Array[Node]
var toolbox_hiden : bool = false

#region LEVEL INITIALIZATION

func _ready() -> void:
	if level_props == null:
		print("LevelPropsResource is not set on level.")
		return

	level_info.level_props = level_props
	if level_props.objects_config:
		var objects :Array[ToolBoxItem] = level_props.objects_config.bake_objects()
		toolbox.items = objects
		var tabs_to_show: Array[ObjectsDescription.HelpTab] = []
		for tab in objects:
			tabs_to_show.append(tab.corresponding_help_tab)
		%ObjectsDescription.tabs_to_show = tabs_to_show

	init_camera()	
	init_inputs()
	init_validators()
	level_info.show_full_container()

	_default_objects = []
	for node in get_children():
		_default_objects.append(node)
		if node.is_in_group("non_editable"):
			node.set_process_input(false)  # Disable input processing for non-editable nodes
			node.set_process_unhandled_input(false)  # Disable unhandled input processing for non-editable nodes

func init_camera() -> void:
	# Set camera limits based on level limits
	camera.limit_left = level_limits.position.x
	camera.limit_top = level_limits.position.y
	camera.limit_right = level_limits.position.x + level_limits.size.x
	camera.limit_bottom = level_limits.position.y + level_limits.size.y
	# Center the camera based on the level limits
	camera.position = level_limits.position + level_limits.size * 0.5

func init_inputs() -> void:
	if level_props.inputs.size() != level_input_nodes.size():
		_generate_missing_input_nodes()

	for i in range(level_props.inputs.size()):
		var input := level_props.inputs[i]
		var node := level_input_nodes[i]
		var numbers : Array[float] = []
		for n in input:
			numbers.append(float(n))  # Ensure numbers are floats
		node.numbers = numbers

func init_validators() -> void:
	if level_props.outputs.size() != level_output_nodes.size():
		_generate_missing_output_nodes()
	
	for i in range(level_props.outputs.size()):
		var level_output = level_props.outputs[i]
		var o := level_output_nodes[i]
		var numbers : Array[float] = []
		for n in level_output:
			numbers.append(float(n))  # Ensure numbers are floats
		o.expected_numbers = numbers
		
		o.received_wrong_number.connect(func(num) : on_number_received(num, false, false))
		o.received_correct_number.connect(func(num, finished) : on_number_received(num, true, finished))

func _generate_missing_input_nodes() -> void:
	var missing_count = level_props.inputs.size() - level_input_nodes.size()
	var center_origin := level_limits.position + Vector2(level_limits.size.x * 0.25, level_limits.size.y * 0.5)
	
	_generate_nodes(level_input_nodes, missing_count, LevelInput.scene, center_origin)

func _generate_missing_output_nodes() -> void:
	var missing_count = level_props.outputs.size() - level_output_nodes.size()
	var center_origin := level_limits.position + level_limits.size - Vector2(level_limits.size.x * 0.25, level_limits.size.y * 0.5)
	
	_generate_nodes(level_output_nodes, missing_count, OutputValidator.scene, center_origin)

# Generic helper function to generate and arrange nodes
func _generate_nodes(node_array: Array, missing_count: int, scene: PackedScene, center_origin: Vector2) -> void:
	# Create and add missing nodes
	for i in missing_count:
		var new_node := scene.instantiate() as Node2D
		node_array.append(new_node)
		add_child(new_node)
	
	# Position all nodes
	_arrange_nodes_vertically(node_array, center_origin)

# Helper function to arrange nodes vertically around a center point
func _arrange_nodes_vertically(nodes: Array, center_origin: Vector2) -> void:
	for i in range(nodes.size()):
		var node := nodes[i] as Node2D
		var offset_y = (i - nodes.size() * 0.5) * GENERATED_NODES_SPACING
		node.position = center_origin + Vector2(0, offset_y)
		node.set_process_input(false)
		node.set_process_unhandled_input(false)

#endregion

func on_number_received(number: int, correct: bool, finished: bool) -> void:
	if not level_executor.execution_in_progress:
		return  # Evita processamento se a execução já foi encerrada
	
	if not correct:
		fail_level()
		return
	
	if finished:
		print("Validator finished!")
		validators_finished += 1
	
	if validators_finished == level_props.outputs.size():
		level_completed.emit()

func fail_level() -> void:
	level_failed.emit()

func _on_level_failed() -> void:
	print("Level failed!")
	level_executor.finish_execution(false)
	validators_finished = 0

func _on_level_completed() -> void:
	print("Level completed!")
	level_executor.finish_execution(true)
	$AnimationPlayer.play("level_complete")
	level_props.save_as_cleared()	# Save the level as completed


func _go_to_next_level() -> void:
	LevelManager.load_next_level()

func _delete_objects() -> void:
	for i in get_children():
		if i in _default_objects:
			continue
		i.queue_free()

# Pause the input handling for all 2d nodes except the camera and those in the "non_editable" group.
func _pause_input_processing() -> void:
	for node in get_children():
		if node.is_in_group("non_editable"):
			continue
		if not node is Node2D:
			continue
		if node is Camera2D:
			continue
		node.set_process_input(false)  # Disable input processing
		node.set_process_unhandled_input(false)  # Disable unhandled input processing
	if toolbox_hiden:
		return
	toolbox.disable_input()
	toolbox.slide_down(0.7)
	toolbox_hiden = true

func _resume_input_processing() -> void:
	for node in get_children():
		if node.is_in_group("non_editable"):
			continue
		if not node is Node2D:
			continue
		if node is Camera2D:
			continue
		node.set_process_input(true)  # Enable input processing
		node.set_process_unhandled_input(true)  # Enable unhandled input processing
	if not toolbox_hiden:
		return
	toolbox.enable_input()
	toolbox.slide_up(0.7)
	toolbox_hiden = false

func _on_back_button_pressed() -> void:
	SceneManager.go_to_last_ui_scene()
