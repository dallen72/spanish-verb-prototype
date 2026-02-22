extends Control

## Controller for Pronoun Matching Game (MVC)

# Domain model - contains all game logic
@onready var session = $SessionState

@onready var signals = Global.get_node("Signals")
@onready var game_progress = Global.get_node("GameProgressMaster")

var UIUtils = Global.get_node("UIUtils")


func _ready():
	session.pronoun_selected.connect($UIManager.on_session_pronoun_selected)
	session.match_made.connect(_on_session_match_made)
	session.match_failed.connect(_on_session_match_failed)

	session.setup_exercise_data(game_progress.get_current_verb(), game_progress.current_exercise)	
	populate_UI()
	
	
## Wrapper function
func populate_UI():
	$UIManager.set_label_text(game_progress.current_exercise.label_text_for_given)
	$UIManager.setup_UI(game_progress.get_current_verb(), session.selected_pronoun, _on_conjugation_button_pressed)
	
	
func _on_session_match_made(pronoun: String, conjugation: String, english_phrase: String):
	"""Updates UI when a match is made in the domain model."""
	var pronoun_button = $UIManager.pronoun_buttons.get(pronoun)
	var conjugation_button = $UIManager.conjugation_buttons.get(conjugation)
	
	if pronoun_button and pronoun_button is PronounButton:
		# Update pronoun button to completed state
		pronoun_button.set_state(PronounButton.ButtonState.COMPLETED)
		pronoun_button.update_text_for_match(conjugation, session.exercise.name, english_phrase)
	
	if conjugation_button:
		# Mark conjugation button as matched
		conjugation_button.modulate = Color.LIGHT_BLUE
		conjugation_button.disabled = true

func _on_session_match_failed():
	"""Handles UI feedback when a match fails."""
	# Notify main script of error
	Global.get_node("Signals").emit_signal("wrong_selection")
	
	# Clear conjugation selection visual feedback
	$UIManager.clear_conjugation_selections()

# ===== UI Helper Methods =====




func _on_conjugation_button_pressed(button: Button):
	"""Handles conjugation button clicks - forwards to domain model."""
	if not session:
		return
	
	# If conjugation button is already matched, ignore clicks
	if button.disabled:
		return
	
	var conjugation = button.text
	
	# Forward match attempt to domain model
	if not session.attempt_match(conjugation):
		UIUtils.flash_button_red_for_error(button)
	
	# If no pronoun is selected, just highlight the conjugation
	if session.selected_pronoun.is_empty():
		$UIManager.clear_conjugation_selections()
		button.modulate = Color.GREEN
