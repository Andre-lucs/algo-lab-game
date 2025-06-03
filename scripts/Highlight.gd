extends Node

enum HighlightLength {
	SHORT,
	MEDIUM,
	LONG
}

func highlight(options : HighlightOptions, length : HighlightLength, custom_color: Color = Global.Colors["white"]) -> void:
	get_tree().call_group(
		options.bake_group_name(),
		"highlight",
		length, custom_color
	)

func highlight_type_compact(type: HighlightOptions.ObjectType,flow_in: bool, flow_out: bool, length: HighlightLength = HighlightLength.SHORT, custom_color: Color = Global.Colors["ligth_blue"]) -> void:
	var options := HighlightOptions.new()
	options.type = type
	options.flow_in = flow_in
	options.flow_out = flow_out
	Highlight.highlight(options, length, custom_color)