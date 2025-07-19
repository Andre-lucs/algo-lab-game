class_name EventTracking

const SAVE_CONFIG_FILE := "user://event_tracking.cfg"

static func track_event(event_name:String, times_occurred:int) -> void:
	var config := ConfigFile.new()
	config.load(SAVE_CONFIG_FILE)
	config.set_value("event_tracking", event_name, times_occurred)
	config.save(SAVE_CONFIG_FILE)

static func get_event_count(event_name:String) -> int:
	var config := ConfigFile.new()
	if config.load(SAVE_CONFIG_FILE) == OK:
		return config.get_value("event_tracking", event_name, 0)
	return 0

static func increment_event_count(event_name:String, increment:int = 1) -> void:
	var current_count := get_event_count(event_name)
	track_event(event_name, current_count + increment)

#region Debugging functions
# Resets all event tracking data, useful for debugging or resetting the game state.
static func reset_event_tracking() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_CONFIG_FILE) == OK:
		config.clear()  # Clear all saved data
		config.save(SAVE_CONFIG_FILE) 
	
#endregion