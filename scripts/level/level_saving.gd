class_name LevelSaving extends Object

const SAVE_CONFIG_FILE := "user://level_save.cfg" 

# Saves the completion status of a level.
static func save_level_completion(level: LevelPropsResource, completed: bool) -> void:
	var save = ConfigFile.new()
	save.load(SAVE_CONFIG_FILE)  # Load existing save data or create a new one if it doesn't exist
	
	save.set_value("LevelClearing", level.resource_path, completed)
	var error = save.save(SAVE_CONFIG_FILE)
	if error != OK:
		print("Error saving level completion status: ", error)

# Checks if a level is completed based on the saved data.
static func is_level_completed(level: LevelPropsResource) -> bool:
	var save = ConfigFile.new()
	var error = save.load(SAVE_CONFIG_FILE)
	if error != OK:
		print("Error loading level completion status: ", error)
		return false
	
	return save.get_value("LevelClearing", level.resource_path, false)
