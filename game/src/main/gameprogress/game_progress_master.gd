extends Node

@onready var signals = Global.get_node("Signals")

var verb_scores: Dictionary
var next_verb: Verb
var current_verb: Verb
var lessons_unlocked_list: Array[String]
var loaded_lesson: Dictionary = {}
var name_of_lesson_in_queue: String

var game_exercises: Array[Exercise]
var current_exercise: Exercise

var total_mistakes: ResponsiveValue = ResponsiveValue.new(0)
var previous_score: int = 0

@onready var global_signals = Global.get_node("Signals")

func _ready():
	name_of_lesson_in_queue = ""
	load_game_progress_for_lessons()
	_init_verb_score_list()
	game_exercises = ExerciseDataAccess.fetch_exercise_list()
	global_signals.wrong_selection.connect(on_wrong_selection)
	

# TODO: load from save game data
func load_game_progress_for_lessons():
	lessons_unlocked_list = []


# TODO: make a structure or something for loading the lessons. so that it doesn't always load the game progress lesson.
func load_lesson_in_queue():
	loaded_lesson = Lesson.get_lesson_by_name(Global.GAME_PROGRESS_LESSON_NAME)
	name_of_lesson_in_queue = ""


func on_wrong_selection():
	total_mistakes.value += 1

	
# initialize the verb scores or load them from save
func _init_verb_score_list() -> void:
	for verb in VerbData.VERB_LIST:
		verb_scores[verb.name] = 0


# update the verb score after doing a problem
func update_verb_score_after_exercise():
	verb_scores[current_verb.name] -= total_mistakes.value


func determine_what_lessons_have_been_unlocked():
	var game_progress_lesson_was_unlocked = lessons_unlocked_list.has(Global.GAME_PROGRESS_LESSON_NAME)
	Lesson.unlock_lesson_if_criteria_met(current_exercise, previous_score, lessons_unlocked_list)
	if (not game_progress_lesson_was_unlocked and lessons_unlocked_list.has(Global.GAME_PROGRESS_LESSON_NAME)):
		name_of_lesson_in_queue = Global.GAME_PROGRESS_LESSON_NAME


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
		printerr("No Verb was able to be fetched with the name of the lowest score verb in get_next_verb()")
		return Verb.new()


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
	total_mistakes.value = 0
