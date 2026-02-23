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
	if not english_pronoun_mode_button.button_pressed:
		english_pronoun_mode_button.button_pressed = true
		return
	
	set_mode("english_pronoun_matching")

func _on_spanish_pronoun_mode_button_pressed():
	if not spanish_pronoun_mode_button.button_pressed:
		spanish_pronoun_mode_button.button_pressed = true
		return
	
	set_mode("spanish_pronoun_matching")

func _on_sentence_mode_button_pressed():
	if not sentence_mode_button.button_pressed:
		sentence_mode_button.button_pressed = true
		return
	
	set_mode("sentence_completion")

func set_mode(mode: String):
	var _list = ExerciseDataAccess.fetch_exercise_list().filter(func(exercise): return exercise.name == mode)
	assert(_list.size() > 0)

	var exercise_containing_the_name: Exercise = _list[0]
	
	# Update current mode
	current_mode = mode
	
	# Update button states
	english_pronoun_mode_button.button_pressed = (mode == "english_pronoun_matching")
	spanish_pronoun_mode_button.button_pressed = (mode == "spanish_pronoun_matching")
	sentence_mode_button.button_pressed = (mode == "sentence_completion")

	game_progress.current_exercise = exercise_containing_the_name

	# Emit signal to parent
	exercise_changed.emit()


# Public method to set initial mode (useful when instantiating)
func set_initial_mode(mode: String):
	set_mode(mode)
