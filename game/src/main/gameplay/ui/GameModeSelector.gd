extends HFlowContainer

# Signals for communicating with parent scenes
signal exercise_changed(mode: String)

# UI references
@onready var english_pronoun_mode_button: Button = $EnglishPronounModeButton
@onready var spanish_pronoun_mode_button: Button = $SpanishPronounModeButton
@onready var sentence_mode_button: Button = $SentenceModeButton

# Current active mode
var current_mode: String = "english_pronouns"

func _ready():
	# Connect button signals
	english_pronoun_mode_button.pressed.connect(_on_english_pronoun_mode_button_pressed)
	spanish_pronoun_mode_button.pressed.connect(_on_spanish_pronoun_mode_button_pressed)
	sentence_mode_button.pressed.connect(_on_sentence_mode_button_pressed)

func _on_english_pronoun_mode_button_pressed():
	if not english_pronoun_mode_button.button_pressed:
		english_pronoun_mode_button.button_pressed = true
		return
	
	set_mode("english_pronouns")

func _on_spanish_pronoun_mode_button_pressed():
	if not spanish_pronoun_mode_button.button_pressed:
		spanish_pronoun_mode_button.button_pressed = true
		return
	
	set_mode("spanish_pronouns")

func _on_sentence_mode_button_pressed():
	if not sentence_mode_button.button_pressed:
		sentence_mode_button.button_pressed = true
		return
	
	set_mode("sentence_completion")

func set_mode(mode: String):
	# Update current mode
	current_mode = mode
	
	# Update button states
	english_pronoun_mode_button.button_pressed = (mode == "english_pronouns")
	spanish_pronoun_mode_button.button_pressed = (mode == "spanish_pronouns")
	sentence_mode_button.button_pressed = (mode == "sentence_completion")
	
	# Emit signal to parent
	exercise_changed.emit(mode)

# Public method to set initial mode (useful when instantiating)
func set_initial_mode(mode: String):
	set_mode(mode)
