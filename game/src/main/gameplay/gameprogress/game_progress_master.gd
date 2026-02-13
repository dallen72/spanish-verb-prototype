extends Node

var verb_scores: Dictionary
var next_verb: Verb


func _ready():
	_init_verb_score_list()
	_init_exercises()
	
	
# initialize the verb scores or load them from save
func _init_verb_score_list() -> void:
	for verb in VerbData.VERB_LIST:
		verb_scores[verb.name] = 0


# update the verb score after doing a problem
func update_verb_score(verb, num_mistakes):
	verb_scores[verb.name].score -= num_mistakes


# get the next verb in the list to be practiced
func get_next_verb() -> Verb:
	var lowest_score_verb = {"dummy": 10000,}
	for verb in verb_scores:
		if verb.score < lowest_score_verb.score:
			lowest_score_verb = verb
	return lowest_score_verb


## TODO: where does everything else go? everything below this line


# Game state variables - accessible globally
var current_exercise: Exercise
var game_exercises: Array[Exercise]
var current_verb: Verb
var completed_verbs: Dictionary = {}
var total_errors: int = 0
var previous_score: int = 0

	
func _init_exercises():
	game_exercises = ExerciseDataAccess.fetch_exercise_list()

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

func get_current_exercise():
	if current_exercise == null:
		return get_exercise_where_name_is("english_pronoun_matching")
	else:
		return current_exercise
			
func get_exercise_where_name_is(exercise_name):
	for exercise in game_exercises:
		if exercise.name == exercise_name:
			return exercise

func init_new_problem():
	# Select a random verb that hasn't been completed yet
	current_verb = get_random_noncompleted_verb()
	
	# If all verbs completed, reset and start over
	if get_verbs_completed_for_excercise().size() >= VerbDataAccess.get_total_verb_count():
		clear_completed_verbs()
		current_verb = get_random_verb()
	
	# Set the current verb in GameProgressMaster
	set_current_verb(current_verb)
		
	# Reset previous score for next problem
	reset_previous_score()
		



################################

func get_random_verb() -> Verb:
	var list = VerbData.VERB_LIST
	return VerbDataAccess.parse_verb(list[randi() % list.size()])



func _get_noncompleted_verb_list(completed_verb_names: Array) -> Array[Verb]:
	var result: Array[Verb] = []
	for raw in VerbData.VERB_LIST:
		var name_str: String = raw.get("name", "")
		if name_str not in completed_verb_names:
			result.append(VerbDataAccess.parse_verb(raw))
	return result


func get_random_noncompleted_verb() -> Verb:
	var completed_verb_names = get_verbs_completed_for_excercise()
	var available = _get_noncompleted_verb_list(completed_verb_names)
	if available.size() > 0:
		return available[randi() % available.size()]
	return get_random_verb()
