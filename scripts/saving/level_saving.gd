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

#region Debugging funcions
# Marks all levels as completed for debugging purposes.
static func complete_every_level() -> void:
	var save = ConfigFile.new()
	save.load(SAVE_CONFIG_FILE)  # Load existing save data or create a new one if it doesn't exist
	
	var levels := []
	for levels_in_set in LevelManager.levels.values():
		levels.append_array(levels_in_set)
	for level in levels:
		save.set_value("LevelClearing", level.resource_path, true)
	
	var error = save.save(SAVE_CONFIG_FILE)
	if error != OK:
		print_debug("Error saving all levels as completed: ", error)
	else:
		print_debug("All levels marked as completed successfully.")

# Erases all saved data, useful for debugging or resetting the game state.
static func erase_save_data() -> void:
	var save = ConfigFile.new()
	var error = save.load(SAVE_CONFIG_FILE)
	if error != OK:
		print_debug("Error loading save data to erase: ", error)
		return
	
	save.clear()  # Clear all saved data
	error = save.save(SAVE_CONFIG_FILE)
	if error != OK:
		print_debug("Error erasing save data: ", error)
	else:
		print_debug("Save data erased successfully.")

#endregion
