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

func _ready():
	# Set initial state to unmatched
	# Wait a frame to ensure theme is loaded
	call_deferred("set_state", State.UNMATCHED)

func set_state(new_state: State):
	"""Updates the button state and appearance."""
	current_state = new_state
	
	match current_state:
		State.UNMATCHED:
			# Unmatched: normal appearance, disabled so user can't click
			# Make disabled buttons look like normal buttons by copying the normal style
			modulate = Color.WHITE
			disabled = true
			# Copy the normal style to disabled so it looks normal
			# Try to get the normal style from theme
			var normal_style = get_theme_stylebox("normal")
			if normal_style:
				# Duplicate the normal style for disabled state
				var disabled_style = normal_style.duplicate()
				add_theme_stylebox_override("disabled", disabled_style)
			else:
				# Fallback: create a default normal-looking style that matches conjugation buttons
				var style = StyleBoxFlat.new()
				# Match the default button appearance
				style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
				style.border_color = Color(0.4, 0.4, 0.4, 1.0)
				style.border_width_left = 2
				style.border_width_top = 2
				style.border_width_right = 2
				style.border_width_bottom = 2
				style.corner_radius_top_left = 4
				style.corner_radius_top_right = 4
				style.corner_radius_bottom_left = 4
				style.corner_radius_bottom_right = 4
				add_theme_stylebox_override("disabled", style)
		
		State.SELECTED:
			# Selected: green color, disabled (user can't click)
			modulate = Color.GREEN
			disabled = true
		
		State.COMPLETED:
			# Completed: light blue color, disabled, text updated
			modulate = Color.LIGHT_BLUE
			disabled = true

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
