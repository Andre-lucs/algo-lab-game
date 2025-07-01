extends Node

const LEVELS_ROOT := "res://levels/level_data"

var test_level : PackedScene = preload("res://levels/test_level.tscn")
var base_level_scene : PackedScene = preload("uid://b8g8dmlr8xrvm")

var current_level : LevelPropsResource = null
var current_level_instance : Level = null

var levels : Dictionary[LevelSet, Array] = {}
var level_sets : Array[LevelSet] = []
# Since the scope of the game isn't big we load all levels data at once.
func _ready():
	_load_levels_data()

func load_test_level():
	var test_level_instance := test_level.instantiate() as Level
	SceneManager.change_scene_to_node(test_level_instance)
	# Set the current level to null to indicate no specific level is loaded
	current_level = test_level_instance.level_props
	current_level_instance = test_level_instance
	
func load_level(level: LevelPropsResource):
	if level == null:
		print("LevelPropsResource is not set.")
		load_test_level()
		return
	var level_instance = level.custom_layout.instantiate() if level.custom_layout else base_level_scene.instantiate()
	level_instance.set("level_props", level)
	SceneManager.change_scene_to_node(level_instance)
	current_level = level
	current_level_instance = level_instance as Level

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

func get_level_sets() -> Array[LevelSet]:
	if level_sets.is_empty(): # Ensure level sets are loaded
		_load_level_sets()
	return level_sets

func _load_level_sets():
	var dir = DirAccess.open(LEVELS_ROOT)
	if dir:
		var directories := dir.get_directories()
		directories.remove_at(directories.find("_template"))
		level_sets = []
		for directory in directories:
			var res_path = LEVELS_ROOT.path_join(directory).path_join("config.tres")
			var res = load(res_path)
			if res is LevelSet:
				level_sets.append(res as LevelSet)
			else:
				print("Resource at %s is not a LevelSet." % res_path)

func _load_levels_data():
	if not levels.is_empty():
		print("Levels already loaded, skipping initialization in LevelManager _ready.")
		return
	# Load all levels from the LEVELS_ROOT directory
	var levelSets := get_level_sets()
	for lvl_set in levelSets:
		var level_list := lvl_set.get_levels()
		if level_list.size() > 0:
			levels[lvl_set] = level_list
			print("Loaded levels from set: ", lvl_set, " - Count: ", level_list.size())
		else:
			print("No levels found in set: ", lvl_set)
