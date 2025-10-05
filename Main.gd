extends Control

# Game state variables
var selected_pronoun: String = ""
var selected_conjugation: String = ""
var previous_score: int = 0
var completed_verbs: Array = []
var current_verb: Dictionary = {}
var total_errors: int = 0
var game_mode: String = "english_pronouns"  # "english_pronouns" or "spanish_pronouns"
var selected_english_phrase: String = ""

# Verb data - enhanced with English phrases
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
@onready var english_pronoun_mode_button: Button = $HeaderContainer/TitleSection/GameModeSelector/EnglishPronounModeButton
@onready var spanish_pronoun_mode_button: Button = $HeaderContainer/TitleSection/GameModeSelector/SpanishPronounModeButton
@onready var sentence_mode_button: Button = $HeaderContainer/TitleSection/GameModeSelector/SentenceModeButton
@onready var pronoun_container: GridContainer = $VBoxContainer/GameArea/PronounSection/PronounGrid
@onready var english_container: GridContainer = $VBoxContainer/GameArea/EnglishSection/EnglishGrid
@onready var conjugation_container: GridContainer = $VBoxContainer/GameArea/ConjugationSection/ConjugationGrid
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
	english_pronoun_mode_button.pressed.connect(_on_english_pronoun_mode_button_pressed)
	spanish_pronoun_mode_button.pressed.connect(_on_spanish_pronoun_mode_button_pressed)
	sentence_mode_button.pressed.connect(_on_sentence_mode_button_pressed)
	
	# Connect pronoun button signals
	for button in pronoun_container.get_children():
		if button is Button:
			button.pressed.connect(_on_pronoun_button_pressed.bind(button))
	
	# Connect English phrase button signals
	for button in english_container.get_children():
		if button is Button:
			button.pressed.connect(_on_english_button_pressed.bind(button))

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
	update_game_mode_display()
	
	# Reset selection state
	selected_pronoun = ""
	selected_conjugation = ""
	selected_english_phrase = ""
	previous_score = 0
	
	# Clear and regenerate conjugation buttons
	clear_conjugation_buttons()
	generate_conjugation_buttons()
	
	# Reset button states based on game mode
	if game_mode == "english_pronouns":
		reset_english_buttons()
	else:  # spanish_pronouns
		reset_pronoun_buttons()
	
	# Update progress indicator
	update_progress_indicator()

func clear_conjugation_buttons():
	for child in conjugation_container.get_children():
		child.queue_free()

func generate_conjugation_buttons():
	var conjugations = current_verb["conjugations"]
	var conjugation_values = []
	
	# Create buttons for each conjugation
	for pronoun in conjugations.keys():
		var conjugation = conjugations[pronoun]
		var button = Button.new()
		button.text = conjugation
		button.custom_minimum_size = Vector2(120, 60)
		button.pressed.connect(_on_conjugation_button_pressed.bind(button))
		conjugation_values.append({"button": button, "conjugation": conjugation, "pronoun": pronoun})
	
	# Shuffle the conjugations for random placement
	conjugation_values.shuffle()
	
	# Add buttons to the grid
	for item in conjugation_values:
		conjugation_container.add_child(item["button"])

func reset_pronoun_buttons():
	for button in pronoun_container.get_children():
		if button is Button:
			button.disabled = false
			button.modulate = Color.WHITE
			button.text = button.name + "..."

func _on_pronoun_button_pressed(button: Button):
	if selected_conjugation != "":
		# Check if this is a correct match
		var pronoun = button.name
		if current_verb["conjugations"][pronoun] == selected_conjugation:
			# Correct match!
			show_match(button, get_conjugation_button_by_text(selected_conjugation))
			if all_are_matched():
				show_popup()
				await get_tree().create_timer(2.0).timeout
				hide_popup()
				completed_verbs.append(current_verb["name"])
				start_new_problem()
			selected_pronoun = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			previous_score += 1
			total_errors += 1
			update_progress_indicator()
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_pronoun = button.name

func _on_conjugation_button_pressed(button: Button):
	var conjugation = button.text
	
	if game_mode == "spanish_pronouns" and selected_pronoun != "":
		# Check if this is a correct match
		if current_verb["conjugations"][selected_pronoun] == conjugation:
			# Correct match!
			show_match(get_pronoun_button_by_name(selected_pronoun), button)
			if all_are_matched():
				show_popup()
				await get_tree().create_timer(2.0).timeout
				hide_popup()
				completed_verbs.append(current_verb["name"])
				start_new_problem()
			selected_pronoun = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			previous_score += 1
			total_errors += 1
			update_progress_indicator()
	elif game_mode == "english_pronouns" and selected_english_phrase != "":
		# Check if this is a correct match
		if current_verb["conjugations"][selected_english_phrase] == conjugation:
			# Correct match!
			show_match(get_english_button_by_pronoun(selected_english_phrase), button)
			if all_are_matched():
				show_popup()
				await get_tree().create_timer(2.0).timeout
				hide_popup()
				completed_verbs.append(current_verb["name"])
				start_new_problem()
			selected_english_phrase = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			previous_score += 1
			total_errors += 1
			update_progress_indicator()
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_conjugation = button.text

func clear_selections():
	# Clear pronoun button selections
	for button in pronoun_container.get_children():
		if button is Button:
			button.modulate = Color.WHITE
	
	# Clear English button selections
	for button in english_container.get_children():
		if button is Button:
			button.modulate = Color.WHITE
	
	# Clear conjugation button selections
	for button in conjugation_container.get_children():
		if button is Button:
			button.modulate = Color.WHITE

func show_match(pronoun_button: Button, conjugation_button: Button):
	# Mark both buttons as correct
	pronoun_button.modulate = Color.LIGHT_BLUE
	conjugation_button.modulate = Color.LIGHT_BLUE
	
	# Disable both buttons
	pronoun_button.disabled = true
	conjugation_button.disabled = true
	
	# Update text to show the match
	pronoun_button.text = pronoun_button.name + " " + conjugation_button.text

func all_are_matched() -> bool:
	var matched_count = 0
	var container_to_check = pronoun_container if game_mode == "spanish_pronouns" else english_container
	
	for button in container_to_check.get_children():
		if button is Button and button.disabled:
			matched_count += 1
	return matched_count >= 6

func show_popup():
	popup.visible = true
	popup_label.text = "Good Job!"

func hide_popup():
	popup.visible = false

func get_conjugation_button_by_text(text: String) -> Button:
	for button in conjugation_container.get_children():
		if button is Button and button.text == text:
			return button
	return null

func get_pronoun_button_by_name(name: String) -> Button:
	for button in pronoun_container.get_children():
		if button is Button and button.name == name:
			return button
	return null

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

func _on_english_pronoun_mode_button_pressed():
	if not english_pronoun_mode_button.button_pressed:
		english_pronoun_mode_button.button_pressed = true
		return
	
	game_mode = "english_pronouns"
	spanish_pronoun_mode_button.button_pressed = false
	sentence_mode_button.button_pressed = false
	update_game_mode_display()
	start_new_problem()

func _on_spanish_pronoun_mode_button_pressed():
	if not spanish_pronoun_mode_button.button_pressed:
		spanish_pronoun_mode_button.button_pressed = true
		return
	
	game_mode = "spanish_pronouns"
	english_pronoun_mode_button.button_pressed = false
	sentence_mode_button.button_pressed = false
	update_game_mode_display()
	start_new_problem()

func _on_sentence_mode_button_pressed():
	get_tree().change_scene_to_file("res://SentenceCompletion.tscn")

func update_game_mode_display():
	if game_mode == "english_pronouns":
		verb_label.text = "Match the English pronoun with the Spanish conjugation for " + current_verb["name"]
		# Show English section, hide Spanish pronoun section
		english_container.get_parent().visible = true
		pronoun_container.get_parent().visible = false
	else:  # spanish_pronouns
		verb_label.text = "Match the Spanish pronoun with the Spanish conjugation for " + current_verb["name"]
		# Show Spanish pronoun section, hide English section
		pronoun_container.get_parent().visible = true
		english_container.get_parent().visible = false

func _on_english_button_pressed(button: Button):
	if game_mode != "english_pronouns":
		return
	
	if selected_conjugation != "":
		# Check if this is a correct match
		var pronoun = button.name.replace("_eng", "")
		if current_verb["conjugations"][pronoun] == selected_conjugation:
			# Correct match!
			show_match(button, get_conjugation_button_by_text(selected_conjugation))
			if all_are_matched():
				show_popup()
				await get_tree().create_timer(2.0).timeout
				hide_popup()
				completed_verbs.append(current_verb["name"])
				start_new_problem()
			selected_english_phrase = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			previous_score += 1
			total_errors += 1
			update_progress_indicator()
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_english_phrase = button.name.replace("_eng", "")

func reset_english_buttons():
	for button in english_container.get_children():
		if button is Button:
			button.disabled = false
			button.modulate = Color.WHITE
			var pronoun = button.name.replace("_eng", "")
			button.text = current_verb["english_phrases"][pronoun] + "..."

func get_english_button_by_pronoun(pronoun: String) -> Button:
	for button in english_container.get_children():
		if button is Button and button.name == pronoun + "_eng":
			return button
	return null
