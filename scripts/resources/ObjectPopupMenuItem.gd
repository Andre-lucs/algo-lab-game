extends Resource
class_name ObjectPopupMenuItem

enum MenuItemType {
	Default, SubMenu
}

@export var frames : Array[Texture2D] = []
@export var text : String
@export var initial_frame : int = 0
@export var type : MenuItemType = MenuItemType.Default

var custom_callback : Callable
var current_frame := 0 

func getInstance() -> DefaultMenuItem:
	var item :DefaultMenuItem
	match type:
		MenuItemType.Default : 
			item = DefaultMenuItem.new() 
			item.auto_next_frame = true
		MenuItemType.SubMenu : 
			item = SubMenuItem.new()
			item.auto_next_frame = false
	
	item.frames = frames
	item.initial_frame = initial_frame
	item.custom_callback = custom_callback
	item.tooltip_text = text
	return item

