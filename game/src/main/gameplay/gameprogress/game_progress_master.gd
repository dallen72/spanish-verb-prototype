extends Node

var verb_scores: Dictionary
var next_verb: Verb
var current_verb: Verb

var game_exercises: Array[Exercise]
var current_exercise: Exercise

var total_errors: ResponsiveValue = ResponsiveValue.new(0)
var previous_score: int = 0

@onready var global_signals = Global.get_node("Signals")

func _ready():
	_init_verb_score_list()
	game_exercises = ExerciseDataAccess.fetch_exercise_list()
	global_signals.wrong_selection.connect(on_wrong_selection)
	current_exercise = Global.initial_exercise
	

func on_wrong_selection():
	total_errors.value += 1

	
# initialize the verb scores or load them from save
func _init_verb_score_list() -> void:
	for verb in VerbData.VERB_LIST:
		verb_scores[verb.name] = 0


# update the verb score after doing a problem
func update_verb_score(verb, num_mistakes):
	verb_scores[verb.name] -= num_mistakes


# get the next verb in the list to be practiced
func get_next_verb() -> Verb:
	assert(verb_scores.size() > 0)
	var lowest_score_verb = verb_scores.keys()[0]
	for verb in verb_scores:
		if verb_scores[verb] < verb_scores[lowest_score_verb]:
			lowest_score_verb = verb
	var verb_object = VerbDataAccess.fetch_verb_where_name_is(lowest_score_verb)
	if verb_object is Verb:
		return verb_object
	else:
		print("No Verb was able to be fetched with the name of the lowest score verb in get_next_verb()")
		return Verb.new()
		


#TODO: delete
func get_current_verb() -> Verb:
	return current_verb

#TODO: delete
func set_current_verb(verb: Verb):
	current_verb = verb


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
	current_verb = get_next_verb()
	previous_score = 0
	total_errors.value = 0
