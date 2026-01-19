extends Button
class_name PronounButton

# Finite state machine for pronoun buttons
enum State {
	UNMATCHED,  # Default state - not selected, not matched
	SELECTED,   # Currently selected (waiting for conjugation match)
	COMPLETED   # Successfully matched with a conjugation
}

var current_state: State = State.UNMATCHED
var pronoun_name: String = ""

# Reference to a conjugation button to get default colors
var conjugation_button_reference: Button = null

func set_conjugation_button_reference(ref_button: Button):
	"""Sets a reference to a conjugation button to match its colors."""
	conjugation_button_reference = ref_button

func get_conjugation_button_colors() -> Dictionary:
	"""Gets the default colors from conjugation buttons."""
	var colors = {
		"bg_color": Color(0.2, 0.2, 0.2, 0.8),  # Default fallback
		"font_color": Color(0.8, 0.8, 0.8, 1.0)  # Default fallback
	}
	
	if conjugation_button_reference:
		# Get the normal style from the conjugation button
		var normal_style = conjugation_button_reference.get_theme_stylebox("normal")
		if normal_style:
			if normal_style is StyleBoxFlat:
				colors["bg_color"] = normal_style.bg_color
			elif normal_style.has_method("get_bg_color"):
				colors["bg_color"] = normal_style.get_bg_color()
		
		# Get font color from conjugation button
		var font_color = conjugation_button_reference.get_theme_color("font_color")
		if font_color:
			colors["font_color"] = font_color
	else:
		# Try to get from theme directly
		var normal_style = get_theme_stylebox("normal")
		if normal_style and normal_style is StyleBoxFlat:
			colors["bg_color"] = normal_style.bg_color
		
		var font_color = get_theme_color("font_color")
		if font_color:
			colors["font_color"] = font_color
	
	return colors

func _ready():
	# Set initial state to unmatched
	# Wait a frame to ensure theme is loaded
	call_deferred("set_state", State.UNMATCHED)

func set_state(new_state: State):
	"""Updates the button state and appearance."""
	current_state = new_state
	
	match current_state:
		State.UNMATCHED:
			# Unmatched: match conjugation button appearance (brown background, brown text)
			modulate = Color.WHITE
			disabled = true  # Disabled to prevent clicks
			mouse_filter = Control.MOUSE_FILTER_IGNORE  # Also ignore clicks
			
			# Get conjugation button colors
			var colors = get_conjugation_button_colors()
			
			# Override disabled style to match conjugation button normal style
			var disabled_style = StyleBoxFlat.new()
			disabled_style.bg_color = colors["bg_color"]
			disabled_style.border_color = Color(0.4, 0.4, 0.4, 1.0)
			disabled_style.border_width_left = 2
			disabled_style.border_width_top = 2
			disabled_style.border_width_right = 2
			disabled_style.border_width_bottom = 2
			disabled_style.corner_radius_top_left = 4
			disabled_style.corner_radius_top_right = 4
			disabled_style.corner_radius_bottom_left = 4
			disabled_style.corner_radius_bottom_right = 4
			add_theme_stylebox_override("disabled", disabled_style)
			
			# Override font color to match conjugation button text color (brown)
			add_theme_color_override("font_color", colors["font_color"])
			add_theme_color_override("font_disabled_color", colors["font_color"])
		
		State.SELECTED:
			# Selected: green color, ignore mouse clicks
			modulate = Color.GREEN
			disabled = false  # Keep enabled so it looks normal
			mouse_filter = Control.MOUSE_FILTER_IGNORE  # But ignore clicks
		
		State.COMPLETED:
			# Completed: light blue color, disabled, text updated
			modulate = Color.LIGHT_BLUE
			disabled = true
			mouse_filter = Control.MOUSE_FILTER_IGNORE

func is_unmatched() -> bool:
	return current_state == State.UNMATCHED

func is_selected() -> bool:
	return current_state == State.SELECTED

func is_completed() -> bool:
	return current_state == State.COMPLETED

func update_text_for_match(conjugation_text: String, game_mode: String, english_phrase: String = ""):
	"""Updates the button text to show the completed match."""
	if game_mode == "english_pronouns" and english_phrase != "":
		text = english_phrase + " " + conjugation_text
	else:
		text = pronoun_name + " " + conjugation_text
