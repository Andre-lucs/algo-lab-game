extends CanvasLayer

# Animation settings
const TRANSITION_DURATION: float = 0.5
const EASING := Tween.EaseType.EASE_IN
const TRANSITION := Tween.TransitionType.TRANS_SINE

# State variables
var current_directory_index: int = 0
var worlds_containers: Array[CenterContainer] = []

# Data references
@onready var directories := LevelManager.get_directories()

# Scene references
# Using load instead of preload to avoid circular dependency
@onready var start_screen: PackedScene = load("uid://c4ug13k78jvr")

# UI references
@onready var level_displaying_container: GridContainer = %LevelDisplaying
@onready var back_levels_button: Control = %BackLevelsButton
@onready var next_levels_button: Control = %NextLevelsButton

func _ready() -> void:
	_setup_initial_state()
	_initialize_level_display()
	_display_initial_directory()

#region INITIALIZATION METHODS

func _setup_initial_state() -> void:
	%BaseLevelSelectButton.hide()

func _initialize_level_display() -> void:
	"""Create and setup level containers for each directory."""
	level_displaying_container.hide()
	
	for directory in directories:
		var world_container := _create_world_container(directory)
		var center_container := _create_center_container(world_container)
		add_child(center_container)
		worlds_containers.append(center_container)

func _create_world_container(directory: String) -> GridContainer:
	"""Create a container with level buttons for the given directory."""
	var levels := LevelManager.get_levels_from_directory(directory)
	var world_container := level_displaying_container.duplicate()
	world_container.show()
	
	for i in levels.size():
		var level_button := _create_level_button(levels[i], i + 1)
		world_container.add_child(level_button)
	
	return world_container

func _create_level_button(level: LevelPropsResource, level_number: int) -> Control:
	"""Create and configure a level selection button."""
	var button := %BaseLevelSelectButton.duplicate()
	button.show()
	button.level_props = level
	button.level_number = level_number
	button.pressed.connect(_open_level.bind(level))
	return button

func _create_center_container(world_container: GridContainer) -> CenterContainer:
	"""Create and configure a center container for the world container."""
	var center_container := CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.add_child(world_container)
	center_container.hide()  # Hide initially
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return center_container

func _display_initial_directory() -> void:
	"""Display the first directory by default."""
	# TODO: Store the last selected directory in a save file
	display_directory_by_index(current_directory_index)

#endregion

#region DIRECTORY NAVIGATION

func display_directory_by_index(index: int) -> void:
	if not _is_valid_directory_index(index):
		return
	
	var next_container = worlds_containers[index]
	if next_container:
		next_container.show()

	_animate_directory_transition(index, next_container)
	current_directory_index = index
	_update_navigation_visibility()

func _is_valid_directory_index(index: int) -> bool:
	"""Check if the directory index is valid."""
	if index < 0 or index >= directories.size():
		printerr("Invalid directory index: ", index)
		return false
	return true

func _animate_directory_transition(target_index: int, next_container: CenterContainer) -> void:
	var direction := clampf(current_directory_index - target_index, -1, 1)
	
	if direction != 0:
		_animate_previous_container_exit(direction)
		_animate_next_container_entrance(next_container, direction)

func _animate_previous_container_exit(direction: float) -> void:
	var prev_container = worlds_containers[current_directory_index]
	if not prev_container:
		return
		
	var tween := create_tween().set_ease(EASING).set_trans(TRANSITION)
	tween.parallel().tween_property(prev_container, "anchor_left", direction, TRANSITION_DURATION)
	tween.parallel().tween_property(prev_container, "anchor_right", direction + 1, TRANSITION_DURATION)
	tween.tween_callback(prev_container.hide)

func _animate_next_container_entrance(next_container: CenterContainer, direction: float) -> void:
	if not next_container:
		return
		
	# Set initial position
	next_container.anchor_left = -direction
	next_container.anchor_right = 1 - direction
	
	# Animate to final position
	var tween = create_tween().set_ease(EASING).set_trans(TRANSITION).set_parallel(true)
	

	tween.tween_property(next_container, "anchor_left", 0, TRANSITION_DURATION)
	tween.tween_property(next_container, "anchor_right", 1, TRANSITION_DURATION)

func _update_navigation_visibility() -> void:
	back_levels_button.visible = current_directory_index > 0
	next_levels_button.visible = current_directory_index < directories.size() - 1

func load_past_levels() -> void:
	if current_directory_index > 0:
		display_directory_by_index(current_directory_index - 1)
	else:
		printerr("No previous directory available.")

func load_next_levels() -> void:
	if current_directory_index < directories.size() - 1:
		display_directory_by_index(current_directory_index + 1)
	else:
		printerr("No next directory available.")

#endregion

#region LEVEL MANAGEMENT

func _open_level(level: LevelPropsResource) -> void:
	if level == null:
		printerr("LevelPropsResource is not set.")
		return
	LevelManager.load_level(level)

#endregion

#region EVENT HANDLERS

func _on_back_button_pressed() -> void:
	SceneManager.change_scene(start_screen)
