class_name DefaultMenuItem extends TextureButton

@export var frames : Array[Texture2D] = []
@export var tooltips : Array[String] = []
@export var initial_frame : int = 0
@export var auto_next_frame : bool = false

var current_frame := 0 
var custom_callback : Callable:
	set(value):
		custom_callback = value
		if pressed.is_connected(custom_callback): return
		pressed.connect(custom_callback)

func _ready() -> void:
	custom_minimum_size = Vector2(32, 32)
	set_frame(initial_frame)
	if !pressed.is_connected(custom_callback):
		pressed.connect(custom_callback)
	if auto_next_frame and !pressed.is_connected(next_frame):
		pressed.connect(next_frame)

func next_frame() -> void:
	if frames.size() <= 1: return
	var new_frame = current_frame + 1
	if new_frame >= frames.size():
		new_frame = 0
	set_frame(new_frame)

func set_frame(value : int) -> void:
	if value < 0 or value >= frames.size():
		return
	current_frame = value
	if tooltips.size() > value:
		tooltip_text = tooltips[value]
	else:
		tooltip_text = ""
	var frame_texture := frames[value]
	texture_normal = frame_texture

static func from_resource(resource: ObjectPopupMenuItem) -> DefaultMenuItem:
	var item := DefaultMenuItem.new()
	item.frames = resource.frames
	item.initial_frame = resource.initial_frame
	item.custom_callback = resource.custom_callback
	item.tooltip_text = resource.text
	return item