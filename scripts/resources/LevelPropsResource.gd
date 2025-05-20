extends Resource
class_name LevelPropsResource

@export var level_name: String
@export var level_description: String

@export var inputs : Array[PackedInt32Array] = []
@export var outputs : Array[PackedInt32Array] = []

@export var custom_layout: PackedScene
