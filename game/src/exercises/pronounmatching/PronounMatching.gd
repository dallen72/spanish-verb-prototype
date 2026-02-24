extends Control

## Controller for Pronoun Matching Game (MVC)

# Domain model - contains all game logic
@onready var session = $SessionState

@onready var signals = Global.get_node("Signals")
@onready var game_progress = Global.get_node("GameProgressMaster")

var UIUtils = Global.get_node("UIUtils")

signal match_made(pronoun: String, conjugation: String, english_phrase: String)
signal match_failed

func _ready():
	session.pronoun_selected.connect($UIManager.update_pronoun_selection)
	session.setup_exercise_data(game_progress.get_current_verb(), game_progress.current_exercise)	
	populate_UI()
	
	match_failed.connect(_on_session_match_failed)
	match_made.connect(_on_session_match_made)
	
	
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

## Attempts to match the selected pronoun with a conjugation.
## Returns true if match is correct, false otherwise.
func attempt_match(conjugation: String) -> bool:
	if session.selected_pronoun.is_empty():
		return false
	
	if not session.verb_data or session.verb_data.conjugations.is_empty():
		return false
	
	var correct_conjugation = session.verb_data.conjugations.get(session.selected_pronoun, "")
	if conjugation != correct_conjugation:
		match_failed.emit()
		return false
	
	return true


## handler for clicking on a conjugation to match the pronoun
func _on_conjugation_button_pressed(button: Button):
	if button.disabled:
		return

	var match_attempt_success = attempt_match(button.text)
	if not match_attempt_success:
		UIUtils.flash_button_red_for_error(button)
	else:		
		# get english phrase if english pronoun matching. TODO: handle somewhere else
		var english_phrase := ""
		if session.exercise.name == "english_pronoun_matching" and session.verb_data.english_phrases.size() > 0:
			english_phrase = session.verb_data.english_phrases.get(session.selected_pronoun, "")
		
		# Record the match. TODO: handle some other way
		var match_pair = {
			"pronoun": session.selected_pronoun,
			"conjugation": button.text,
			"english_phrase": english_phrase
		}
		session.matched_pairs.append(match_pair)
		
		# Remove from available pronouns
		session.available_pronouns.erase(session.selected_pronoun)
		

		
		
		match_made.emit(session.selected_pronoun, button.text, english_phrase)
		if session.is_complete():
			Global.get_node("Signals").emit_signal("problem_completed")
			session.selected_pronoun = ""
		else:
			session.select_next_pronoun()
