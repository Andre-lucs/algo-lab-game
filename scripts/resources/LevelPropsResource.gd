extends Resource
class_name LevelPropsResource

@export var level_name: String
@export_multiline var level_description: String

@export var inputs : Array[PackedInt32Array] = []
@export var outputs : Array[PackedInt32Array] = []

@export var custom_layout: PackedScene

@export var available_objects: Array[ToolBoxItem]
