
extends Node

# TODO: make sure this is just state and setters and getters. the root node has the controller script.

# Domain model for pronoun matching game logic
# This class contains NO UI dependencies - pure game logic only

# Game state
var verb_data: Verb = null
var exercise: Exercise
var selected_pronoun: String = ""
var matched_pairs: Array[Dictionary] = []  # Array of {pronoun: String, conjugation: String, english_phrase: String}
var available_pronouns: Array[String] = []  # Pronouns not yet matched

# Signals for UI to observe state changes
signal pronoun_selected(pronoun: String)
signal match_made(pronoun: String, conjugation: String, english_phrase: String)
signal match_failed()
signal session_started(exercise: String)

func start_problem(verb: Verb, _exercise: Exercise):
	"""Initializes a new matching session with a verb and game mode."""
	verb_data = verb
	exercise = _exercise
	selected_pronoun = ""
	matched_pairs.clear()
	available_pronouns.clear()
	
	# Initialize available pronouns from verb data
	if verb_data and verb_data.conjugations.size() > 0:
		for pronoun in verb_data.conjugations.keys():
			available_pronouns.append(pronoun)
	
	# Select the first pronoun automatically
	if available_pronouns.size() > 0:
		select_pronoun(available_pronouns[0])
	
	session_started.emit(exercise)

## Sets the given pronoun to selected
func select_pronoun(pronoun: String):
	"""Selects a pronoun for matching. Returns true if successful."""
	if not is_pronoun_available(pronoun):
		return false
	
	selected_pronoun = pronoun
	
	pronoun_selected.emit(pronoun)
	return true


func attempt_match(conjugation: String) -> bool:
	"""
	Attempts to match the selected pronoun with a conjugation.
	Returns true if match is correct, false otherwise.
	"""
	if selected_pronoun.is_empty():
		return false
	
	if not verb_data or verb_data.conjugations.is_empty():
		return false
	
	var correct_conjugation = verb_data.conjugations.get(selected_pronoun, "")
	if conjugation != correct_conjugation:
		match_failed.emit()
		return false
	
	# Correct match!
	var english_phrase := ""
	if exercise.name == "english_pronoun_matching" and verb_data.english_phrases.size() > 0:
		english_phrase = verb_data.english_phrases.get(selected_pronoun, "")
	
	# Record the match
	var match_pair = {
		"pronoun": selected_pronoun,
		"conjugation": conjugation,
		"english_phrase": english_phrase
	}
	matched_pairs.append(match_pair)
	
	# Remove from available pronouns
	available_pronouns.erase(selected_pronoun)
	
	match_made.emit(selected_pronoun, conjugation, english_phrase)

	# Check if session is complete
	if is_complete():
		Global.get_node("Signals").emit_signal("problem_completed")
		selected_pronoun = ""
	else:
		# Select next available pronoun
		select_next_pronoun()
	
	return true


func select_next_pronoun():
	"""Automatically selects the next available pronoun."""
	if available_pronouns.size() > 0:
		select_pronoun(available_pronouns[0])
	else:
		selected_pronoun = ""


func is_pronoun_available(pronoun: String) -> bool:
	"""Checks if a pronoun is still available for matching."""
	return pronoun in available_pronouns


func is_pronoun_matched(pronoun: String) -> bool:
	"""Checks if a pronoun has been matched."""
	for pair in matched_pairs:
		if pair.get("pronoun", "") == pronoun:
			return true
	return false

func is_complete() -> bool:
	"""Checks if all pronouns have been matched."""
	return available_pronouns.size() == 0

func get_correct_conjugation_for(pronoun: String) -> String:
	"""Returns the correct conjugation for a given pronoun."""
	if not verb_data or verb_data.conjugations.is_empty():
		return ""
	return verb_data.conjugations.get(pronoun, "")

func get_english_phrase_for(pronoun: String) -> String:
	"""Returns the English phrase for a given pronoun (if in english_pronoun_matching mode)."""
	if exercise.name != "english_pronoun_matching" or not verb_data or verb_data.english_phrases.is_empty():
		return ""
	return verb_data.english_phrases.get(pronoun, "")

func get_matched_pair_for(pronoun: String) -> Dictionary:
	"""Returns the match pair for a given pronoun, or empty dict if not matched."""
	for pair in matched_pairs:
		if pair.get("pronoun", "") == pronoun:
			return pair
	return {}

func get_all_pronouns() -> Array[String]:
	"""Returns all pronouns for the current verb."""
	if not verb_data or verb_data.conjugations.is_empty():
		return []
	return verb_data.conjugations.keys()



func setup_initial_problem():
	"""Sets up the initial problem when the scene loads."""
	# Ensure we have a game mode (default to english_pronouns)
	
	# Ensure current_verb is set
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# If current_verb is not set, set it now
	if current_verb == null:
		current_verb = game_progress.get_next_verb()
		
	start_problem(current_verb, Global.initial_exercise)
