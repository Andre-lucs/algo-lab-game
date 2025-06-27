extends CanvasLayer

# Using load instead of preload to avoid circular dependency
@onready var start_screen : PackedScene = load("uid://c4ug13k78jvr") 
@onready var directories := LevelManager.get_directories()

@onready var level_displaying_container : GridContainer = %LevelDisplaying

func _ready() -> void:
	# TODO store the last selected directory in a variable
	display_levels_on_directory(directories[0])

# TODO make an animation for swapping directories
func display_levels_on_directory(directory: String) -> void:
	var levels := LevelManager.get_levels_from_directory(directory)
	if levels.size() == 0:
		printerr("No levels found in directory: ", directory)
		return
	
	for i in level_displaying_container.get_children():
		i.queue_free()  # Clear previous buttons

	for level in levels:
		# TODO use a custom button to display level information
		var button := Button.new()
		button.text = level.level_name
		button.custom_minimum_size = Vector2(64,64)
		button.pressed.connect(_open_level.bind(level))
		level_displaying_container.add_child(button)

func _open_level(level: LevelPropsResource) -> void:
	if level == null:
		printerr("LevelPropsResource is not set.")
		return
	LevelManager.load_level(level)

func _on_back_button_pressed() -> void:
	SceneManager.change_scene(start_screen)
