extends Control

# Game state variables
var previous_score: int = 0
var completed_verbs: Array = []
var current_verb: Dictionary = {}
var total_errors: int = 0
var current_conjugation_for_sentences: String = ""
var current_pronoun_for_sentences: String = ""

# Verb data - enhanced with English phrases and sentence templates
const VERB_LIST = [
	{
		"name": "Tener",
		"conjugations": {
			"yo": "tengo",
			"tu": "tienes", 
			"el": "tiene",
			"nosotros": "tenemos",
			"vosotros": "tenéis",
			"ellos": "tienen"
		},
		"english_phrases": {
			"yo": "I have",
			"tu": "You have",
			"el": "He/She has",
			"nosotros": "We have",
			"vosotros": "You all have",
			"ellos": "They have"
		},
		"sentence_templates": {
			"yo": "___ tengo hambre",
			"tu": "¿___ tienes tiempo?",
			"el": "___ tiene un coche",
			"nosotros": "___ tenemos clase",
			"vosotros": "¿___ tenéis dinero?",
			"ellos": "___ tienen muchos amigos"
		},
		"ending": "er"
	},
	{
		"name": "Hablar",
		"conjugations": {
			"yo": "hablo",
			"tu": "hablas",
			"el": "habla", 
			"nosotros": "hablamos",
			"vosotros": "hablais",
			"ellos": "hablan"
		},
		"english_phrases": {
			"yo": "I speak",
			"tu": "You speak",
			"el": "He/She speaks",
			"nosotros": "We speak",
			"vosotros": "You all speak",
			"ellos": "They speak"
		},
		"sentence_templates": {
			"yo": "___ hablo español",
			"tu": "¿___ hablas inglés?",
			"el": "___ habla francés",
			"nosotros": "___ hablamos mucho",
			"vosotros": "¿___ habláis italiano?",
			"ellos": "___ hablan chino"
		},
		"ending": "ar"
	},
	{
		"name": "Vivir",
		"conjugations": {
			"yo": "vivo",
			"tu": "vives",
			"el": "vive",
			"nosotros": "vivimos", 
			"vosotros": "vivis",
			"ellos": "viven"
		},
		"english_phrases": {
			"yo": "I live",
			"tu": "You live",
			"el": "He/She lives",
			"nosotros": "We live",
			"vosotros": "You all live",
			"ellos": "They live"
		},
		"sentence_templates": {
			"yo": "___ vivo en Madrid",
			"tu": "¿___ vives aquí?",
			"el": "___ vive en Barcelona",
			"nosotros": "___ vivimos juntos",
			"vosotros": "¿___ vivís cerca?",
			"ellos": "___ viven en París"
		},
		"ending": "ir"
	}
]

# UI references
@onready var verb_label: Label = $HeaderContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/TitleSection/PreviousScoreLabel
@onready var pronoun_mode_button: Button = $HeaderContainer/TitleSection/GameModeSelector/PronounModeButton
@onready var english_mode_button: Button = $HeaderContainer/TitleSection/GameModeSelector/EnglishModeButton
@onready var sentence_mode_button: Button = $HeaderContainer/TitleSection/GameModeSelector/SentenceModeButton
@onready var conjugation_display_button: Button = $VBoxContainer/GameArea/ConjugationSection/ConjugationDisplay
@onready var sentence_container: GridContainer = $VBoxContainer/GameArea/SentenceSection/SentenceGrid
@onready var popup: Control = $Popup
@onready var popup_label: Label = $Popup/VBoxContainer/Label

# Progress indicator references
@onready var current_verb_label: Label = $HeaderContainer/ProgressIndicator/VBoxContainer/ContentContainer/LeftColumn/CurrentVerbLabel
@onready var verbs_completed_label: Label = $HeaderContainer/ProgressIndicator/VBoxContainer/ContentContainer/LeftColumn/VerbsCompletedLabel
@onready var verb_ending_label: Label = $HeaderContainer/ProgressIndicator/VBoxContainer/ContentContainer/RightColumn/VerbEndingLabel
@onready var total_errors_label: Label = $HeaderContainer/ProgressIndicator/VBoxContainer/ContentContainer/RightColumn/TotalErrorsLabel

func _ready():
	# Initialize the game with a random verb
	start_new_problem()
	
	# Connect game mode button signals
	pronoun_mode_button.pressed.connect(_on_pronoun_mode_button_pressed)
	english_mode_button.pressed.connect(_on_english_mode_button_pressed)
	sentence_mode_button.pressed.connect(_on_sentence_mode_button_pressed)
	
	# Connect sentence button signals
	for button in sentence_container.get_children():
		if button is Button:
			button.pressed.connect(_on_sentence_button_pressed.bind(button))

func start_new_problem():
	# Select a random verb that hasn't been completed yet
	var available_verbs = []
	for verb in VERB_LIST:
		if not verb["name"] in completed_verbs:
			available_verbs.append(verb)
	
	if available_verbs.size() > 0:
		current_verb = available_verbs[randi() % available_verbs.size()]
	else:
		# All verbs completed, reset and start over
		completed_verbs.clear()
		current_verb = VERB_LIST[randi() % VERB_LIST.size()]
	
	# Update UI
	previous_score_label.text = "You got " + str(previous_score) + " wrong on the last problem"
	update_verb_label()
	
	# Reset selection state
	current_conjugation_for_sentences = ""
	current_pronoun_for_sentences = ""
	previous_score = 0
	
	# Setup sentence completion mode
	setup_sentence_completion_mode()
	
	# Update progress indicator
	update_progress_indicator()

func update_verb_label():
	verb_label.text = "Match the conjugation with the correct sentence for " + current_verb["name"]

func setup_sentence_completion_mode():
	# Pick a random conjugation to display
	var pronouns = current_verb["conjugations"].keys()
	var random_pronoun = pronouns[randi() % pronouns.size()]
	current_pronoun_for_sentences = random_pronoun
	current_conjugation_for_sentences = current_verb["conjugations"][random_pronoun]
	
	# Set the conjugation display button
	conjugation_display_button.text = current_conjugation_for_sentences
	
	# Reset sentence buttons
	for button in sentence_container.get_children():
		if button is Button:
			button.disabled = false
			button.modulate = Color.WHITE
			var pronoun = button.name.replace("sentence_", "")
			button.text = current_verb["sentence_templates"][pronoun]

func _on_sentence_button_pressed(button: Button):
	var pronoun = button.name.replace("sentence_", "")
	
	# Check if this is the correct match
	if pronoun == current_pronoun_for_sentences:
		# Correct match!
		button.modulate = Color.LIGHT_BLUE
		button.disabled = true
		button.text = current_verb["sentence_templates"][pronoun].replace("___", current_pronoun_for_sentences)
		
		# Mark as completed and move to next problem
		show_popup()
		await get_tree().create_timer(2.0).timeout
		hide_popup()
		completed_verbs.append(current_verb["name"])
		start_new_problem()
	else:
		# Incorrect match
		previous_score += 1
		total_errors += 1
		update_progress_indicator()
		
		# Visual feedback for wrong answer
		button.modulate = Color.RED
		await get_tree().create_timer(0.5).timeout
		button.modulate = Color.WHITE

func update_progress_indicator():
	# Update current verb
	current_verb_label.text = "Current: " + current_verb["name"]
	
	# Update verbs completed
	var total_verbs = VERB_LIST.size()
	var completed_count = completed_verbs.size()
	
	verbs_completed_label.text = "Completed: " + str(completed_count) + "/" + str(total_verbs)
	
	# Update verb ending
	verb_ending_label.text = "Ending: -" + current_verb["ending"]
	
	# Update total errors
	total_errors_label.text = "Total Errors: " + str(total_errors)

func show_popup():
	popup.visible = true
	popup_label.text = "Good Job!"

func hide_popup():
	popup.visible = false

# Game mode switching functions
func _on_pronoun_mode_button_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_english_mode_button_pressed():
	# For now, just show a message - we could create an English matching scene too
	print("English matching mode - would switch to English matching scene")

func _on_sentence_mode_button_pressed():
	# Already in sentence mode, do nothing
	pass
