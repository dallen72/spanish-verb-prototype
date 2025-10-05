extends Control

# Game state variables
var previous_score: int = 0
var completed_verbs: Array = []
var current_verb: Dictionary = {}
var total_errors: int = 0
var current_conjugation_for_sentences: String = ""
var current_pronoun_for_sentences: String = ""

# Verb data is now imported from VerbData.gd

# UI references
@onready var verb_label: Label = $HeaderContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/TitleSection/PreviousScoreLabel
@onready var game_mode_selector: HBoxContainer = $HeaderContainer/TitleSection/GameModeSelector
@onready var progress_indicator: Control = $HeaderContainer/ProgressIndicator
@onready var conjugation_display_button: Button = $VBoxContainer/GameArea/ConjugationSection/ConjugationDisplay
@onready var sentence_container: GridContainer = $VBoxContainer/GameArea/SentenceSection/SentenceGrid
@onready var popup: Control = $Popup
@onready var popup_label: Label = $Popup/VBoxContainer/Label

func _ready():
	# Initialize the game with a random verb
	start_new_problem()
	
	# Connect game mode selector signal
	game_mode_selector.game_mode_changed.connect(_on_game_mode_changed)
	
	# Set initial mode to sentence completion
	game_mode_selector.set_initial_mode("sentence_completion")
	
	# Connect sentence button signals
	for button in sentence_container.get_children():
		if button is Button:
			button.pressed.connect(_on_sentence_button_pressed.bind(button))

func start_new_problem():
	# Select a random verb that hasn't been completed yet
	current_verb = VerbData.get_random_available_verb(completed_verbs)
	
	# If all verbs completed, reset and start over
	if completed_verbs.size() >= VerbData.get_total_verb_count():
		completed_verbs.clear()
		current_verb = VerbData.get_random_verb()
	
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
	progress_indicator.update_progress(current_verb, completed_verbs, total_errors)

func show_popup():
	popup.visible = true
	popup_label.text = "Good Job!"

func hide_popup():
	popup.visible = false

# Game mode switching function
func _on_game_mode_changed(mode: String):
	if mode != "sentence_completion":
		get_tree().change_scene_to_file("res://Main.tscn")
	# If mode is sentence_completion, do nothing (already in this scene)
