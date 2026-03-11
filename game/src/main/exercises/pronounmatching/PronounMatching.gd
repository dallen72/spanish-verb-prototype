extends Control

## Controller for Pronoun Matching Game (MVC)

# Domain model - contains all game logic
@onready var session = $SessionState

@onready var signals = Global.get_node("Signals")
@onready var game_progress = Global.get_node("GameProgressMaster")

var UIUtils = Global.get_node("UIUtils")

signal match_failed

func _ready():
	session.selected_pronoun.changed.connect($UIManager.update_pronoun_selection)
	session.setup_exercise_data()	
	populate_UI()
	
	match_failed.connect(_on_session_match_failed)
	
	
## Wrapper function
func populate_UI():
	$UIManager.set_label_text()
	$UIManager.setup_UI(session.selected_pronoun.value, _on_conjugation_button_pressed)
	

## Updates the UI state when a match is made.
func _on_session_match_made(pronoun: String, conjugation: String):
	var pronoun_button = $UIManager.pronoun_buttons.get(pronoun)

	if pronoun_button and pronoun_button is PronounButton:
		pronoun_button.update_text_for_match(conjugation, session.exercise.name, session.get_english_phrase_for(pronoun))	


## Handles UI feedback when a match fails.
func _on_session_match_failed():
	Global.get_node("Signals").emit_signal("wrong_selection")
	$UIManager.clear_conjugation_selection_appearances()


## Attempts to match the selected pronoun with a conjugation.
## Returns true if match is correct, false otherwise.
func attempt_match(conjugation: String) -> bool:
	if session.selected_pronoun.value.is_empty():
		return false
	
	if not session.verb_data or session.verb_data.conjugations.is_empty():
		return false
	
	
	var correct_conjugation = session.verb_data.conjugations.get(session.selected_pronoun.value, "")
	if conjugation != correct_conjugation:
		match_failed.emit()
		return false
	
	return true


## handler for clicking on a conjugation to match the pronoun
func _on_conjugation_button_pressed(button: ConjugationButton):
	if button.disabled:
		return

	var match_attempt_success = attempt_match(button.text)
	if not match_attempt_success:
		button.current_state.value = ConjugationButton.ButtonState.ERRORED
	else:
		_on_session_match_made(session.selected_pronoun.value, button.text)

		session.select_next_pronoun()
		if session.is_complete():
			Global.get_node("Signals").emit_signal("problem_completed")
			
