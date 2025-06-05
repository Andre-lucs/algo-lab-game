class_name HighlightOptions extends Resource

enum ObjectType {
		NUMBER_MOVEMENT,
		ACTIVATABLE,
		CONNECTION_AREA
}

@export var type : ObjectType = ObjectType.NUMBER_MOVEMENT
@export var flow_in := false
@export var flow_out := false

func bake_group_name() -> String:
	var group_name = "highlightable"
	if type == ObjectType.NUMBER_MOVEMENT:
		group_name += "_number_movement"
	elif type == ObjectType.ACTIVATABLE:
		group_name += "_activatable"
	elif type == ObjectType.CONNECTION_AREA:
		group_name += "_connection_area"
	
	if flow_in or flow_out:
		group_name += "_flow"
	if flow_in:
		group_name += "_in"
	if flow_out:
		group_name += "_out"
	return group_name
