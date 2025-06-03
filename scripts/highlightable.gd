class_name Highlightable extends Node

signal highlighted

@export var highlight_options: HighlightOptions
@export_group("Scale Animation")
@export var auto_play_scale_animation: bool = true
@export var scale_target : Node2D
@export var scale_animation_amount: float = 1.2
@export_group("Outline Animation")
@export var auto_play_outline_animation: bool = true
@export var outline_target: CanvasItem
@export var outline_width: float = 5.0

const _highlight_timings = {
	Highlight.HighlightLength.SHORT: 0.2,
	Highlight.HighlightLength.MEDIUM: 0.5,
	Highlight.HighlightLength.LONG: 1.0
}

func _ready() -> void:
	if not highlight_options:
		print_debug("HighlightOptions is not set for " + get_parent().name)
		return
	add_to_group(highlight_options.bake_group_name())

func highlight(length : Highlight.HighlightLength ,custom_color : Color = Color.WHITE) -> void:
	highlighted.emit()
	print(get_parent().name ," highlighted with options: ", highlight_options.bake_group_name())
	if auto_play_scale_animation:
		play_scale_animation(length)
	if auto_play_outline_animation:
		play_outline_animation(length, custom_color)
	
func play_scale_animation(length : Highlight.HighlightLength = Highlight.HighlightLength.SHORT) -> void:
	if not scale_target or scale_animation_amount <= 0:
		return
	var og_scale := scale_target.scale
	var t := create_tween()
	t.tween_property(scale_target, "scale", og_scale * scale_animation_amount, 0.2)
	t.tween_property(scale_target, "scale", og_scale, 0.2).set_delay(_highlight_timings[length])
	t.play()

func play_outline_animation(length : Highlight.HighlightLength = Highlight.HighlightLength.SHORT, color : Color = Global.Colors["red"]) -> void:
	if not outline_target or outline_width <= 0:
		return
	var material = ShaderMaterial.new()
	material.shader = preload("res://assets/outline.gdshader")
	outline_target.material = material
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("width", outline_width)
	
	var t := create_tween()
	t.tween_interval(_highlight_timings[length])
	t.tween_property(material, "shader_parameter/width", 0.0, 0.2)
	t.tween_callback(func():
		outline_target.material = null
	)
	t.play()