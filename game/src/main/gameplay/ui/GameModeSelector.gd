extends HFlowContainer

signal exercise_changed()

# UI references
@onready var english_pronoun_mode_button: Button = $EnglishPronounModeButton
@onready var spanish_pronoun_mode_button: Button = $SpanishPronounModeButton
@onready var sentence_mode_button: Button = $SentenceModeButton

@onready var game_progress: Node = Global.get_node("GameProgressMaster")

# Current active mode
var current_mode: String = "english_pronoun_matching"

func _ready():
	# Connect button signals
	english_pronoun_mode_button.pressed.connect(_on_english_pronoun_mode_button_pressed)
	spanish_pronoun_mode_button.pressed.connect(_on_spanish_pronoun_mode_button_pressed)
	sentence_mode_button.pressed.connect(_on_sentence_mode_button_pressed)

func _on_english_pronoun_mode_button_pressed():	
	set_mode("english_pronoun_matching")
	_set_selectable_button_states("english_pronoun_matching")

func _on_spanish_pronoun_mode_button_pressed():
	set_mode("spanish_pronoun_matching")
	_set_selectable_button_states("english_pronoun_matching")
	

func _on_sentence_mode_button_pressed():
	set_mode("sentence_completion")
	_set_selectable_button_states("english_pronoun_matching")
	

func set_mode(mode: String):
	var _list = ExerciseDataAccess.fetch_exercise_list().filter(func(exercise): return exercise.name == mode)
	assert(_list.size() > 0)

	current_mode = mode
	var exercise_containing_the_name: Exercise = _list[0]	
	game_progress.current_exercise = exercise_containing_the_name

	exercise_changed.emit()


# Public method to set initial mode (useful when instantiating)
func set_initial_mode(mode: String):
	set_mode(mode)
	_set_selectable_button_states(mode)	
	

func _set_selectable_button_states(mode: String):
	english_pronoun_mode_button.button_pressed = (mode == "english_pronoun_matching")
	spanish_pronoun_mode_button.button_pressed = (mode == "spanish_pronoun_matching")
	sentence_mode_button.button_pressed = (mode == "sentence_completion")
