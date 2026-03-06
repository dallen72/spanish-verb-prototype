
extends Node

# Domain model for pronoun matching game logic
@onready var game_progress = Global.get_node("GameProgressMaster")

# Game state
var verb_data: Verb = null
var exercise: Exercise
var selected_pronoun: String = ""
var matched_pairs: Array[Dictionary] = []  # Array of {pronoun: String, conjugation: String, english_phrase: String}
var available_pronouns: Array[String] = []  # Pronouns not yet matched

# Signals for UI to observe state changes
signal pronoun_selected(pronoun: String)

func setup_exercise_data():
	"""Initializes a new matching session with a verb and game mode."""
	verb_data = game_progress.current_verb
	exercise = game_progress.current_exercise
	selected_pronoun = ""
	matched_pairs.clear()
	available_pronouns.clear()
	
	# Initialize available pronouns from verb data
	if verb_data and verb_data.conjugations.size() > 0:
		for pronoun in verb_data.conjugations.keys():
			available_pronouns.append(pronoun)

	select_next_pronoun()


func select_next_pronoun():
	"""Automatically selects the next available pronoun."""
	if available_pronouns.size() > 0:
		selected_pronoun = available_pronouns[0]
		await get_tree().process_frame # TODO: make sure this runs before all ui modification code
		pronoun_selected.emit(selected_pronoun)
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

func update_state_data_for_matching(conjugation: String):
	# get english phrase if english pronoun matching. TODO: handle somewhere else
	var english_phrase := ""
	if exercise.name == "english_pronoun_matching" and verb_data.english_phrases.size() > 0:
		english_phrase = verb_data.english_phrases.get(selected_pronoun, "")
	
	# Record the match. TODO: handle some other way
	var match_pair = {
		"pronoun": selected_pronoun,
		"conjugation": conjugation,
		"english_phrase": english_phrase
	}
	matched_pairs.append(match_pair)
	
	# Remove from available pronouns
	available_pronouns.erase(selected_pronoun)
	
