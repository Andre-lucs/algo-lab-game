@tool
extends MarginContainer

enum HelpTab {
		MovementLink,
		Container,
		Router,
		ActivatorLink,
		Operator,
		Number,
		NameTag
}

const ALL_OBJECT_TYPES : Array[HelpTab] = [
		HelpTab.MovementLink,
		HelpTab.Container,
		HelpTab.Router,
		HelpTab.ActivatorLink,
		HelpTab.Operator,
		HelpTab.Number,
		HelpTab.NameTag
]

signal close_requested

@export var current_tab : HelpTab = HelpTab.MovementLink:
	set(value):
		if value == current_tab:
			return
		animate_tab_change(current_tab, value)
		current_tab = value
		if not is_node_ready():
			return
		# Update the tab bar to show the correct tab
		var tab_index := _get_tab_bar_index_for_type(value)
		if tab_index != -1 and tab_index < tab_bar.tab_count:
			tab_bar.current_tab = tab_index

@export var tabs_to_show : Array[HelpTab] = ALL_OBJECT_TYPES.duplicate():
	set(value):
		tabs_to_show = value
		if is_node_ready():
			_update_tab_bar()
			# Ensure current tab is valid
			if current_tab not in tabs_to_show:
				# Switch to the first available tab
				for tab_type in tabs_to_show:
					if objects_menu_nodes.has(tab_type):
						current_tab = tab_type
						break
			for k in objects_menu_nodes:
				var menu_node := objects_menu_nodes[k]
				if k not in tabs_to_show:
					menu_node.hide()
				if k == current_tab:
					menu_node.show()
				else:
					menu_node.hide()

@export var tab_icons : Dictionary[HelpTab, Texture2D] = {
	HelpTab.MovementLink: preload("res://assets/UI/MenuIcons/PointyArrow.png"),
	HelpTab.Container: preload("res://assets/container.png"),
	HelpTab.Router: preload("res://assets/Router.png"),
	HelpTab.ActivatorLink: preload("res://assets/UI/Electricity.png"),
	HelpTab.Operator: preload("res://assets/MathOperator.png"),
	HelpTab.Number: preload("res://assets/NumberPreview.png"),
	HelpTab.NameTag: preload("res://assets/NameTag.png"),
}

@onready var tab_bar : TabBar = %TabBar

@onready var objects_menu_nodes : Dictionary[HelpTab, Control] = {
		HelpTab.MovementLink: %MovementLinkDescription,
		HelpTab.Container: %ContainerDescription,
		HelpTab.Router: %RouterDescription,
		HelpTab.ActivatorLink: %ActivatorDescription,
		HelpTab.Operator: %OperatorDescription,
		HelpTab.Number: %NumberDescription,
		HelpTab.NameTag: %NameTagDescription
}

# Animation state management
var _active_tweens: Array[Tween] = []
var _is_animating: bool = false
var _pending_tab_change: HelpTab = HelpTab.MovementLink
var _has_pending_change: bool = false

func _ready() -> void:
	pivot_offset = size / 2 # Center the pivot for animations
	_update_tab_bar()
	
	# Only show tabs that are in tabs_to_show
	for type in tabs_to_show:
		if not objects_menu_nodes.has(type):
			continue
		var menu_node := objects_menu_nodes[type]
		if type == current_tab:
			# Find the correct tab index in the filtered tab bar
			var tab_index := _get_tab_bar_index_for_type(type)
			if tab_index != -1:
				tab_bar.current_tab = tab_index
		else:
			menu_node.hide()
	
	# Hide all menus that are not in tabs_to_show
	for type in objects_menu_nodes.keys():
		if type not in tabs_to_show:
			objects_menu_nodes[type].hide()

func _update_tab_bar() -> void:
	# Clear existing tabs
	tab_bar.clear_tabs()
	
	# Add only the tabs that should be shown
	var tab_index := 0
	for type in tabs_to_show:
		if objects_menu_nodes.has(type):
			var tab_icon := _get_tab_icon_for_type(type)
			tab_bar.add_tab("")  # Add empty tab first
			if tab_icon:
				tab_bar.set_tab_icon(tab_index, tab_icon)
			tab_index += 1

func _get_tab_icon_for_type(type: HelpTab) -> Texture2D:
	if tab_icons.has(type):
		return tab_icons[type]
	return null

func _get_tab_bar_index_for_type(type: HelpTab) -> int:
	var index := 0
	for tab_type in tabs_to_show:
		if objects_menu_nodes.has(tab_type):
			if tab_type == type:
				return index
			index += 1
	return -1

func _get_type_for_tab_bar_index(index: int) -> HelpTab:
	var current_index := 0
	for tab_type in tabs_to_show:
		if objects_menu_nodes.has(tab_type):
			if current_index == index:
				return tab_type
			current_index += 1
	return HelpTab.MovementLink # fallback

#region Animation Logic
# This section was mostly written by the AI Claude Sonnet, with some adjustments for clarity and functionality.
# Used ai to save time and effort, but I made sure to understand and adapt the logic to fit the project needs.

func animate_tab_change(old_tab: HelpTab, new_tab: HelpTab) -> void:
	# Check if both tabs are in the allowed tabs and have corresponding menu nodes
	if not (old_tab in tabs_to_show and new_tab in tabs_to_show):
		return
	if not objects_menu_nodes.has(old_tab) or not objects_menu_nodes.has(new_tab):
		current_tab = old_tab
		return
	
	if Engine.is_editor_hint():
		objects_menu_nodes[old_tab].hide()
		objects_menu_nodes[new_tab].show()
		return 
	
	# If currently animating, queue this change
	if _is_animating:
		_pending_tab_change = new_tab
		_has_pending_change = true
		return
	
	# Clean up any existing tweens and reset all menus to proper state
	_cleanup_animations()
	_reset_menu_states()
	
	# Calculate the path of tabs to animate through
	var tab_path := _get_tab_animation_path(old_tab, new_tab)
	if tab_path.size() <= 1:
		return
	
	_is_animating = true
	_animate_tab_sequence(tab_path)

func _cleanup_animations() -> void:
	# Kill all active tweens
	for tween in _active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	_active_tweens.clear()

func _reset_menu_states() -> void:
	# Reset only the menus that are allowed to be shown
	for tab_type in tabs_to_show:
		if not objects_menu_nodes.has(tab_type):
			continue
		var menu := objects_menu_nodes[tab_type]
		menu.hide()
		menu.anchor_left = 0
		menu.anchor_right = 1
	
	# Ensure all non-allowed menus are hidden
	for type in objects_menu_nodes.keys():
		if type not in tabs_to_show:
			objects_menu_nodes[type].hide()
	
	# Show the current tab if it's allowed
	if current_tab in tabs_to_show and objects_menu_nodes.has(current_tab):
		objects_menu_nodes[current_tab].show()

func _on_animation_complete() -> void:
	_is_animating = false
	
	# Process any pending tab change
	if _has_pending_change:
		_has_pending_change = false
		var target_tab = _pending_tab_change
		# Use call_deferred to avoid immediate recursion
		call_deferred("_process_pending_tab_change", target_tab)

func _process_pending_tab_change(target_tab: HelpTab) -> void:
	current_tab = target_tab

func _get_tab_animation_path(old_tab: HelpTab, new_tab: HelpTab) -> Array[HelpTab]:
	var path: Array[HelpTab] = []
	
	# Only include tabs that are in tabs_to_show and have corresponding menu nodes
	var available_tabs: Array[HelpTab] = []
	for tab_type in tabs_to_show:
		if objects_menu_nodes.has(tab_type):
			available_tabs.append(tab_type)
	
	# Find indices in the available tabs array
	var start_idx := available_tabs.find(old_tab)
	var end_idx := available_tabs.find(new_tab)
	
	# If either tab is not found in available tabs, no path can be created
	if start_idx == -1 or end_idx == -1:
		return path
	
	if start_idx == end_idx:
		return path
	
	var direction := 1 if end_idx > start_idx else -1
	var current_idx := start_idx
	
	# Build the path using only available tabs
	while current_idx != end_idx:
		path.append(available_tabs[current_idx])
		current_idx += direction
	path.append(available_tabs[end_idx]) # Add the final tab
	
	return path

func _animate_tab_sequence(tab_path: Array[HelpTab]) -> void:
	if tab_path.size() <= 1:
		_on_animation_complete()
		return
	
	# Duration per transition - shorter for multiple tabs
	var transition_duration := 0.15 if tab_path.size() > 2 else 0.2
	var pause_duration := 0.05 if tab_path.size() > 2 else 0.0
	
	# Create a single master tween to coordinate all animations
	var master_tween := create_tween()
	_active_tweens.append(master_tween)
	
	# Animate each transition in sequence
	for i in range(tab_path.size() - 1):
		var from_tab := tab_path[i]
		var to_tab := tab_path[i + 1]
		
		# Add the transition
		master_tween.tween_callback(_perform_single_transition.bind(from_tab, to_tab, transition_duration))
		master_tween.tween_interval(transition_duration)
		
		# Add pause between transitions (except for the last one)
		if i < tab_path.size() - 2 and pause_duration > 0:
			master_tween.tween_interval(pause_duration)
	
	# Signal completion when done
	master_tween.tween_callback(_on_animation_complete)

func _perform_single_transition(old_tab: HelpTab, new_tab: HelpTab, duration: float) -> void:
	if not objects_menu_nodes.has(old_tab) or not objects_menu_nodes.has(new_tab):
		return
		
	var old_menu := objects_menu_nodes[old_tab]
	var new_menu := objects_menu_nodes[new_tab]
	
	# Calculate direction based on position in tabs_to_show array instead of enum values
	var available_tabs: Array[HelpTab] = []
	for tab_type in tabs_to_show:
		if objects_menu_nodes.has(tab_type):
			available_tabs.append(tab_type)
	
	var old_index := available_tabs.find(old_tab)
	var new_index := available_tabs.find(new_tab)
	var direction := 1 if new_index > old_index else -1
	
	# Setup new menu initial position
	new_menu.anchor_left = 1 * direction
	new_menu.anchor_right = new_menu.anchor_left + 1
	new_menu.show()
	
	# Animate new menu entrance
	var new_menu_tween := create_tween()
	_active_tweens.append(new_menu_tween)
	new_menu_tween.parallel().tween_property(new_menu, "anchor_left", 0, duration)
	new_menu_tween.parallel().tween_property(new_menu, "anchor_right", 1, duration)
	
	# Animate old menu exit
	var old_menu_tween := create_tween()
	_active_tweens.append(old_menu_tween)
	var old_menu_anchor_left := -1 * direction
	old_menu_tween.parallel().tween_property(old_menu, "anchor_left", old_menu_anchor_left, duration)
	old_menu_tween.parallel().tween_property(old_menu, "anchor_right", old_menu_anchor_left + 1, duration)
	old_menu_tween.tween_callback(old_menu.hide)

#endregion

#region ui callbacks

func display_next_menu():
	# Prevent rapid changes during animation
	if _is_animating:
		return
	
	# Get available tabs that are in tabs_to_show and have menu nodes
	var available_tabs: Array[HelpTab] = []
	for tab_type in tabs_to_show:
		if objects_menu_nodes.has(tab_type):
			available_tabs.append(tab_type)
	
	if available_tabs.is_empty():
		return
	
	# Find current tab index in available tabs
	var current_index := available_tabs.find(current_tab)
	if current_index == -1:
		current_tab = available_tabs.front()
		return
	
	# Move to next available tab or wrap around
	var next_index := (current_index + 1) % available_tabs.size()
	current_tab = available_tabs[next_index]

func display_previous_menu():
	# Prevent rapid changes during animation
	if _is_animating:
		return
	
	# Get available tabs that are in tabs_to_show and have menu nodes
	var available_tabs: Array[HelpTab] = []
	for tab_type in tabs_to_show:
		if objects_menu_nodes.has(tab_type):
			available_tabs.append(tab_type)
	
	if available_tabs.is_empty():
		return
	
	# Find current tab index in available tabs
	var current_index := available_tabs.find(current_tab)
	if current_index == -1:
		current_tab = available_tabs.back()
		return
	
	# Move to previous available tab or wrap around
	var prev_index := (current_index - 1 + available_tabs.size()) % available_tabs.size()
	current_tab = available_tabs[prev_index]

func _on_tab_bar_tab_changed(tab_index: int) -> void:
	# Convert tab bar index to HelpTab
	var target_tab := _get_type_for_tab_bar_index(tab_index)
	# Only allow tab changes to tabs that are in tabs_to_show
	if target_tab in tabs_to_show:
		current_tab = target_tab

func _on_close_button_pressed() -> void:
	# Emit signal to notify that the close button was pressed
	close_requested.emit()
	print("Close button pressed, emitting close_requested signal.")

#endregion
