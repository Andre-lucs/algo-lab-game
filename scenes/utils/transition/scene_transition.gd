extends CanvasLayer

signal finished

@export var transition_duration : float = 0.5
@export var transition_color : Color = Color(0, 0, 0, 1)
@export_range(0.0,360.0) var rotation_degrees : float = 0.0 :
	set(value):
		rotation_degrees = value
		if not is_inside_tree():
			await ready
		$ColorRect.rotation_degrees = value

@onready var color_rect : ColorRect = $ColorRect
var screen_size : Vector2 = DisplayServer.screen_get_size()

func _ready() -> void:
	hide()

var tween : Tween = null
func play() -> void:
	if not is_inside_tree():
		return
	color_rect.color = transition_color
	color_rect.modulate.a = 1.0
	color_rect.rotation_degrees = rotation_degrees
	var larger_size : float = max(screen_size.x, screen_size.y)
	color_rect.scale = Vector2(larger_size/2, 5)
	show()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(color_rect, "scale", Vector2(larger_size*0.8, 100.0), transition_duration/2).set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.tween_property(color_rect, "scale", Vector2(larger_size, larger_size), transition_duration/2).set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.tween_callback(_on_transition_finished)

func play_backwards():
	if not is_inside_tree():
		return
	color_rect.modulate = transition_color
	color_rect.rotation_degrees = rotation_degrees
	var larger_size : float = max(screen_size.x, screen_size.y)
	color_rect.scale = Vector2(larger_size, larger_size)
	show()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(color_rect, "scale", Vector2(larger_size/2, 5), transition_duration/2).set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.tween_property(color_rect, "scale", Vector2(0, 0), transition_duration/2).set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.parallel().tween_property(color_rect, "modulate:a", 0, transition_duration/2).set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.tween_callback(hide)
	tween.tween_callback(_on_transition_finished)

func _on_transition_finished():
	finished.emit()
