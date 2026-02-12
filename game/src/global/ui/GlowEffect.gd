extends Node
class_name GlowEffect

# Creates a pulsing glow outline effect for UI elements

var glow_panels: Array[Panel] = []
var glow_pulse_time: float = 0.0
var glow_pulse_speed: float = 2.0  # Speed of the pulse animation
var glow_color_base: Color = Color(0.2, 0.6, 1.0)  # Base color for the glow
var glow_alpha_min: float = 0.3
var glow_alpha_max: float = 0.8
var border_width: int = 4
var corner_radius: int = 8

# Target elements to track (Control nodes)
var target_elements: Array[Control] = []

func _ready():
	set_process(true)

func _process(delta):
	# Update glow pulse animation
	glow_pulse_time += delta * glow_pulse_speed
	
	# Calculate pulse value (0.0 to 1.0, oscillating)
	var pulse_value = (sin(glow_pulse_time) + 1.0) / 2.0  # 0.0 to 1.0
	var glow_alpha = glow_alpha_min + (pulse_value * (glow_alpha_max - glow_alpha_min))
	var glow_color = Color(glow_color_base.r, glow_color_base.g, glow_color_base.b, glow_alpha)
	
	# Update all glow panels
	for i in range(glow_panels.size()):
		var panel = glow_panels[i]
		if not is_instance_valid(panel):
			continue
		
		var style_box = panel.get_theme_stylebox("panel")
		if style_box is StyleBoxFlat:
			style_box.border_color = glow_color
		
		# Update position and size to match target element
		if i < target_elements.size():
			var target = target_elements[i]
			if is_instance_valid(target):
				update_glow_panel_position(panel, target)

func add_glow_to_element(element: Control, parent: Control = null):
	"""
	Adds a pulsing glow outline to a UI element.
	
	Args:
		element: The Control node to add a glow to
		parent: The parent node to add the glow panel to (defaults to element's parent)
	"""
	if not is_instance_valid(element):
		return null
	
	var target_parent = parent if parent else element.get_parent()
	if not is_instance_valid(target_parent):
		return null
	
	# Create a StyleBoxFlat for the outline
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	style_box.border_color = Color(glow_color_base.r, glow_color_base.g, glow_color_base.b, 0.0)
	style_box.border_width_left = border_width
	style_box.border_width_top = border_width
	style_box.border_width_right = border_width
	style_box.border_width_bottom = border_width
	style_box.corner_radius_top_left = corner_radius
	style_box.corner_radius_top_right = corner_radius
	style_box.corner_radius_bottom_left = corner_radius
	style_box.corner_radius_bottom_right = corner_radius
	
	# Create a Panel that will overlay the element
	var glow_panel = Panel.new()
	glow_panel.add_theme_stylebox_override("panel", style_box)
	glow_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow_panel.z_index = 1  # Above the element
	
	# Add to parent
	target_parent.add_child(glow_panel)
	
	# Store references
	glow_panels.append(glow_panel)
	target_elements.append(element)
	
	# Set initial position and size
	update_glow_panel_position(glow_panel, element)
	
	return glow_panel

func update_glow_panel_position(glow_panel: Panel, target: Control):
	"""Updates the glow panel position and size to match the target element."""
	if not is_instance_valid(glow_panel) or not is_instance_valid(target):
		return
	
	# Calculate position relative to the glow panel's parent
	var target_global_pos = target.get_global_position()
	var parent_global_pos = glow_panel.get_parent().get_global_position()
	var relative_pos = target_global_pos - parent_global_pos
	
	glow_panel.position = relative_pos - Vector2(border_width, border_width)
	glow_panel.size = target.size + Vector2(border_width * 2, border_width * 2)

func remove_all_glows():
	"""Removes all glow effects."""
	for panel in glow_panels:
		if is_instance_valid(panel):
			panel.queue_free()
	glow_panels.clear()
	target_elements.clear()
