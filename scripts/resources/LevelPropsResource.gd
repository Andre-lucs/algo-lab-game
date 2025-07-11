extends Resource
class_name LevelPropsResource

@export var level_name: String
@export_multiline var level_description: String

@export var inputs : Array[PackedInt32Array] = []
@export var outputs : Array[PackedInt32Array] = []

@export var custom_layout: PackedScene

@export var objects_config: ObjectListConfiguration

func was_cleared() -> bool:
	return LevelSaving.is_level_completed(self)

func save_as_cleared() -> void:
	LevelSaving.save_level_completion(self, true)