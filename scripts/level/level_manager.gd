extends Node

const LEVELS_ROOT := "res://levels/level_data"

var test_level : PackedScene = preload("res://levels/test_level.tscn")

var layouts := [
]

var current_level : LevelPropsResource = null

var levels : Dictionary[String, Array] = {}
# Since the scope of the game isn't big we load all levels data at once.
func _ready():
	_load_levels_data()

func get_random_layout() -> PackedScene:
	return layouts.pick_random()

func load_test_level():
	SceneManager.change_scene(test_level)
	
func load_level(level: LevelPropsResource):
	if level == null:
		print("LevelPropsResource is not set.")
		load_test_level()
		return
	var layout = level.custom_layout if level.custom_layout else get_random_layout()
	if layout:
		var layout_instance = layout.instantiate()
		layout_instance.set("level_props", level)
		SceneManager.change_scene_to_node(layout_instance)
		current_level = level		
	else:
		print("No layout defined, using default layout.")
		get_tree().change_scene_to_packed(test_level)

func load_next_level():
	if not current_level:
		load_test_level()
		return
	for dir in levels.values():
		var idx = dir.find(current_level)
		if idx != -1 and idx < dir.size() - 1:
			var next_level = dir[idx + 1]
			load_level(next_level)
			return
	
	SceneManager.go_to_last_ui_scene()

func get_directories() -> PackedStringArray:
	var dir = DirAccess.open(LEVELS_ROOT)
	if dir:
		var directories := dir.get_directories()
		directories.remove_at(directories.find("_template"))
		return directories
	else:
		print("Failed to access directory: ", LEVELS_ROOT)
		return []
	
func get_levels_from_directory(directory: String) -> Array[LevelPropsResource]:

	# Check if the levels for this directory are already loaded
	if levels.has(directory):
		return levels[directory]

	var lvl_res : Array[LevelPropsResource] = []
	var res_names := ResourceLoader.list_directory(LEVELS_ROOT.path_join(directory))

	for res_name in res_names:
		
		var res_path = LEVELS_ROOT.path_join(directory).path_join(res_name)
		var res = load(res_path)
		if res is LevelPropsResource:
			lvl_res.append(res as LevelPropsResource)
		else:
			print("Resource at %s is not a LevelPropsResource." % res_path)
	
	return lvl_res

func _load_levels_data():
	if not levels.is_empty():
		print("Levels already loaded, skipping initialization in LevelManager _ready.")
		return
	# Load all levels from the LEVELS_ROOT directory
	var directories = get_directories()
	for directory in directories:
		var level_list = get_levels_from_directory(directory)
		if level_list.size() > 0:
			levels[directory] = level_list
			print("Loaded levels from directory: ", directory, " - Count: ", level_list.size())
		else:
			print("No levels found in directory: ", directory)
