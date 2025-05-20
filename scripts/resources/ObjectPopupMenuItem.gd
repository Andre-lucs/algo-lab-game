extends Resource
class_name ObjectPopupMenuItem

@export var frames : Array[Texture2D] = []
@export var text : String
@export var initial_frame : int = 0

var current_frame := 0 

func next_frame(button : TextureButton) -> void:
	if frames.size() <= 1: return
	var new_frame = current_frame + 1
	if new_frame >= frames.size():
		new_frame = 0
	set_frame(new_frame, button)

func init_button(button : TextureButton) -> void:
	if button:
		button.tooltip_text = text
		set_frame(initial_frame, button)
	else:
		print("Button not set")

func set_frame(value : int, button : TextureButton) -> void:
	if value < 0 or value >= frames.size():
		return
	current_frame = value
	var frame_texture := frames[value]
	button.texture_normal = frame_texture
