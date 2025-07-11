@tool
class_name ObjectListConfiguration extends Resource

enum ObjectsPresets{
	EMPTY, 
	INITAL,
	INTERMEDIATE,
	COMPLETE
}

enum ObjectTypes {
	MOVEMENTLINK,
	ACTIVATIONLINK,
	CONTAINER,
	ROUTER,
	OPERATOR,
	NUMBER,
	NAMETAG
}

static var ObjectsResources := {
	ObjectTypes.MOVEMENTLINK: load("uid://ryjjhxl48x3w"),
	ObjectTypes.ACTIVATIONLINK: load("uid://b1xaq6o4gy17y"),
	ObjectTypes.CONTAINER: load("uid://doehu4k766ac0"),
	ObjectTypes.ROUTER: load("uid://6x4febetlbat"),
	ObjectTypes.OPERATOR: load("uid://dqfohj8in8ax"),
	ObjectTypes.NUMBER: load("uid://bgun6t66qh8oq"),
	ObjectTypes.NAMETAG: load("uid://bqs0ujbufuq3r")
}

const PRESET_VALUES := {
	ObjectsPresets.EMPTY: [],
	ObjectsPresets.INITAL: [
		ObjectTypes.MOVEMENTLINK,
		ObjectTypes.CONTAINER,
		ObjectTypes.ROUTER,
		ObjectTypes.NAMETAG
	],
	ObjectsPresets.INTERMEDIATE: [
		ObjectTypes.MOVEMENTLINK,
		ObjectTypes.ACTIVATIONLINK,
		ObjectTypes.CONTAINER,
		ObjectTypes.ROUTER,
		ObjectTypes.NAMETAG,
	],
	ObjectsPresets.COMPLETE: [
		ObjectTypes.MOVEMENTLINK,
		ObjectTypes.ACTIVATIONLINK,
		ObjectTypes.CONTAINER,
		ObjectTypes.ROUTER,
		ObjectTypes.OPERATOR,
		ObjectTypes.NUMBER,
		ObjectTypes.NAMETAG,
	]
}

@export var items_preset : ObjectsPresets = ObjectsPresets.COMPLETE

## List of objects to be used in the level, (Modifying this from here won't do nothing since the game uses the objects after the baking process).
@export() var objects: Array[ObjectTypes] = []
@export_tool_button("Apply Preset") var apply_preset_button = apply_preset

func apply_preset() -> void:
	if items_preset in PRESET_VALUES:
		objects.clear()
		objects.append_array(PRESET_VALUES[items_preset])
	else:
		print("Warning: Invalid preset selected:", items_preset)

func bake_objects() -> Array[ToolBoxItem]:
	var box_items: Array[ToolBoxItem] = []
	for item in objects:
		if item in ObjectsResources:
			box_items.append(ObjectsResources[item])

	return box_items
