class_name ToolBoxItem extends Resource

const ObjectsDescription = preload("uid://dsighljguajpa")

@export var item_name : String
@export var corresponding_help_tab : ObjectsDescription.HelpTab
@export var icon : Texture2D
@export var preview_image : Texture2D
@export var target_scene : PackedScene
## If false the item the target scene will be instantiated directly, if true the item preview will be used
@export var use_item_preview : bool = true

@export var custom_args : Dictionary[String, Variant] = {}
