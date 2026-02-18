extends Button
class_name PronounButton

# Finite state machine for pronoun buttons
enum ButtonState {
	UNMATCHED,  # Default state - not selected, not matched
	SELECTED,   # Currently selected (waiting for conjugation match)
	COMPLETED   # Successfully matched with a conjugation
}

var current_state: ButtonState = ButtonState.UNMATCHED
var pronoun_name: String = ""

static func _get_global_button_colors() -> Dictionary:
	# Fetch shared button colors from the Global autoload (GameProgressMaster)
	var result := {
		"bg_color": Color(0.2, 0.2, 0.2, 0.8),
		"font_color": Color(0.8, 0.8, 0.8, 1.0),
		"disabled_font_color": Color(0.6, 0.6, 0.6, 1.0),
	}
	if Engine.has_singleton("Global"):
		var root = Engine.get_singleton("Global")
		if root and root.has_node("GameProgressMaster"):
			var gp = root.get_node("GameProgressMaster")
			if gp and gp.has_method("get_conjugation_button_colors"):
				var colors = gp.get_conjugation_button_colors()
				if colors.has("bg_color"):
					result["bg_color"] = colors["bg_color"]
				if colors.has("font_color"):
					result["font_color"] = colors["font_color"]
					result["disabled_font_color"] = colors["font_color"].darkened(0.2)
	return result

func _ready():
	# Set initial state to unmatched
	# Wait a frame to ensure theme and globals are ready
	call_deferred("set_state", ButtonState.UNMATCHED)

func set_state(new_state: ButtonState):
	"""Updates the button state and appearance."""
	current_state = new_state
	var colors = _get_global_button_colors()
	
	match current_state:
		ButtonState.UNMATCHED:
			# Unmatched: use shared brown background and text color, ignore clicks
			modulate = Color.WHITE
			disabled = true
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var disabled_style = StyleBoxFlat.new()
			disabled_style.bg_color = colors["bg_color"]
			disabled_style.corner_radius_top_left = 4
			disabled_style.corner_radius_top_right = 4
			disabled_style.corner_radius_bottom_left = 4
			disabled_style.corner_radius_bottom_right = 4
			add_theme_stylebox_override("disabled", disabled_style)
			
			add_theme_color_override("font_color", colors["font_color"])
			add_theme_color_override("font_disabled_color", colors["disabled_font_color"])
		
		ButtonState.SELECTED:
			# Selected: green color, ignore mouse clicks
			modulate = Color.GREEN
			disabled = false
			mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		ButtonState.COMPLETED:
			# Completed: keep same shared font colors, but use a lighter background
			var completed_style = StyleBoxFlat.new()
			completed_style.bg_color = colors["bg_color"].lightened(0.3)
			completed_style.corner_radius_top_left = 4
			completed_style.corner_radius_top_right = 4
			completed_style.corner_radius_bottom_left = 4
			completed_style.corner_radius_bottom_right = 4
			add_theme_stylebox_override("disabled", completed_style)

			add_theme_color_override("font_color", colors["font_color"])
			add_theme_color_override("font_disabled_color", colors["disabled_font_color"])

			disabled = true
			mouse_filter = Control.MOUSE_FILTER_IGNORE

func is_unmatched() -> bool:
	return current_state == ButtonState.UNMATCHED

func is_selected() -> bool:
	return current_state == ButtonState.SELECTED

func is_completed() -> bool:
	return current_state == ButtonState.COMPLETED

func update_text_for_match(conjugation_text: String, exercise: String, english_phrase: String = ""):
	"""Updates the button text to show the completed match."""
	if exercise == "english_pronoun_matching" and english_phrase != "":
		text = english_phrase + " " + conjugation_text
	else:
		text = pronoun_name + " " + conjugation_text
