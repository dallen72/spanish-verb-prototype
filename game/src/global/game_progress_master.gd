extends Node

# Game state variables - accessible globally
var current_excercise: String
var current_verb: Dictionary = {}
var completed_verbs: Dictionary = {}
var total_errors: int = 0
var previous_score: int = 0

# Shared button colors (for conjugation and pronoun buttons)
var conjugation_button_bg_color: Color = Color(0.2, 0.2, 0.2, 0.8)
var conjugation_button_font_color: Color = Color(0.8, 0.8, 0.8, 1.0)
var conjugation_button_colors_initialized: bool = false

func _ready():
	# Initialize shared button colors when the game loads
	_init_conjugation_button_colors()

func _init_conjugation_button_colors():
	if conjugation_button_colors_initialized:
		return

	# Use the default theme as the source for button colors
	var theme := ThemeDB.get_default_theme()
	if theme:
		# Background color used by buttons (often the \"brown\" shade)
		if theme.has_color("bg_disabled_color", "Button"):
			conjugation_button_bg_color = theme.get_color("bg_disabled_color", "Button")
		elif theme.has_color("bg_color", "Button"):
			conjugation_button_bg_color = theme.get_color("bg_color", "Button")

		# Font color used by buttons
		if theme.has_color("font_color", "Button"):
			conjugation_button_font_color = theme.get_color("font_color", "Button")

	conjugation_button_colors_initialized = true

func get_conjugation_button_colors() -> Dictionary:
	"""
	Returns the shared conjugation/pronoun button colors.
	These are initialized once when the game loads so all buttons stay consistent.
	"""
	if not conjugation_button_colors_initialized:
		_init_conjugation_button_colors()

	return {
		"bg_color": conjugation_button_bg_color,
		"font_color": conjugation_button_font_color,
	}

func set_conjugation_button_colors(bg_color: Color, font_color: Color) -> void:
	"""
	Optional override: if we ever want to change button colors at runtime.
	"""
	conjugation_button_bg_color = bg_color
	conjugation_button_font_color = font_color
	conjugation_button_colors_initialized = true

func get_current_verb() -> Dictionary:
	return current_verb

func set_current_verb(verb: Dictionary):
	current_verb = verb

func add_completed_verb(excercise_name: String, verb_name: String):
	for excercise in completed_verbs:
		if excercise["name"] == excercise_name:	
			if not excercise.verbs.has(verb_name):
				excercise.append("verb_name")

func get_verbs_completed_for_excercise(excercise_name: String = "") -> Array:
	var game_progress = Global.get_node("GameProgressMaster")
	if completed_verbs.has(excercise_name):	
		return completed_verbs[excercise_name]
	elif completed_verbs.size() == 0:
		return []
	elif excercise_name == "":
		return completed_verbs[game_progress.current_excercise]
	else:
		return [] #TODO: should this branch be here?

func clear_completed_verbs():
	completed_verbs.clear()

func increment_total_errors():
	total_errors += 1

func get_total_errors() -> int:
	return total_errors

func set_previous_score(score: int):
	previous_score = score

func get_previous_score() -> int:
	return previous_score

func reset_previous_score():
	previous_score = 0

func get_excercise_data(excercise_name: String) -> Array[String]:
	if completed_verbs.size() > 0:
		return completed_verbs["excercise_name"] if completed_verbs["excercise_name"] == null else []
	else:
		return []

func _get_available_verbs() -> Array:
	var available = []
	for verb in VerbData.VERB_LIST:
		if not verb["name"] in completed_verbs:
			available.append(verb)
	return available

func get_random_available_verb() -> Dictionary:
	var available = _get_available_verbs()
	if available.size() > 0:
		return available[randi() % available.size()]
	else:
		# All verbs completed, return random verb
		return VerbData.get_random_verb()
