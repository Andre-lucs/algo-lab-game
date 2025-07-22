class_name LevelSet extends Resource

@export var level_set_name: String = "Default Level Set"
@export var required_levels: Array[LevelPropsResource] = []
# Array with the LevelSet resources that are required to be completed before this set can be accessed.
@export var required_level_sets: Array[LevelSet] = []

func get_dir_path() -> String:
	"""
	Get the folder path of the level set.
	This is used to load levels from the correct directory.
	"""
	return resource_path.get_base_dir()

func get_levels() -> Array[LevelPropsResource]:
	var lvl_res : Array[LevelPropsResource] = []
	var res_names := ResourceLoader.list_directory(get_dir_path())

	for res_name in res_names:
		
		var res_path = get_dir_path().path_join(res_name)
		# skip if the res_path is not a valid resource
		if not ResourceLoader.exists(res_path):
			continue
		var res = load(res_path)
		if res is LevelPropsResource:
			lvl_res.append(res as LevelPropsResource)
	
	return lvl_res

func is_cleared() -> bool:
	"""
	Check if all required levels in the set are cleared.
	Checking on the save data if the level is cleared.
	"""
	for level in required_levels:
		if not LevelSaving.is_level_completed(level):
			return false
	return true

func can_access() -> bool:
	"""
	Check if the level set can be accessed.
	Checking on the save data if the required levels are cleared.
	"""
	if required_level_sets.is_empty():
		return true  # No requirements, can access freely
	for level_set in required_level_sets:
		if not level_set.is_cleared():
			return false
	return true