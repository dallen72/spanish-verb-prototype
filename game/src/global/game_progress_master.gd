extends Node

# Game state variables - accessible globally
var current_exercise: Exercise
var game_exercises: Array[Exercise]
var current_verb: Verb
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
	_init_exercises()
	
func _init_exercises():
	game_exercises = ExerciseDataAccess.get_exercise_list()

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

func get_current_verb() -> Verb:
	return current_verb

func set_current_verb(verb: Verb):
	current_verb = verb

func add_completed_verb():
	if current_verb and not current_exercise.completed_verbs.has(current_verb.name):
		current_exercise.completed_verbs.append(current_verb.name)

func get_verbs_completed_for_excercise(excercise_name: String = "") -> Array:
	if completed_verbs.has(excercise_name):
		return completed_verbs[excercise_name]
	elif completed_verbs.size() == 0:
		return []
	elif excercise_name == "" and current_exercise != null:
		return current_exercise.completed_verbs
	else:
		return []

func get_completed_verbs() -> Array:
	return get_verbs_completed_for_excercise()

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

func _get_available_verbs() -> Array[Verb]:
	var completed_names = get_verbs_completed_for_excercise()
	return VerbDataAccess.get_available_verbs(completed_names)

func get_random_available_verb() -> Verb:
	var completed_names = get_verbs_completed_for_excercise()
	return VerbDataAccess.get_random_available_verb(completed_names)

func get_current_exercise():
	if current_exercise == null:
		return get_exercise_where_name_is("english_pronoun_matching")
	else:
		return current_exercise

func get_excercise(verb_name):
	for exercise in game_exercises:
		if exercise.name == verb_name:
			return exercise
			
func get_exercise_where_name_is(exercise_name):
	for exercise in game_exercises:
		if exercise.name == exercise_name:
			return exercise

func init_new_problem():
	# Select a random verb that hasn't been completed yet
	current_verb = get_random_available_verb()
	
	# If all verbs completed, reset and start over
	if get_verbs_completed_for_excercise().size() >= VerbDataAccess.get_total_verb_count():
		clear_completed_verbs()
		current_verb = VerbDataAccess.get_random_verb()
	
	# Set the current verb in GameProgressMaster
	set_current_verb(current_verb)
		
	# Reset previous score for next problem
	reset_previous_score()
		
