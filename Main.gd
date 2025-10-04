extends Control

# Game state variables
var selected_pronoun: String = ""
var selected_conjugation: String = ""
var previous_score: int = 0
var completed_verbs: Array = []
var current_verb: Dictionary = {}
var total_errors: int = 0

# Verb data - same as HTML version
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
		"ending": "ir"
	}
]

# UI references
@onready var verb_label: Label = $HeaderContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/TitleSection/PreviousScoreLabel
@onready var pronoun_container: GridContainer = $VBoxContainer/GameArea/PronounSection/PronounGrid
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
	
	# Connect pronoun button signals
	for button in pronoun_container.get_children():
		if button is Button:
			button.pressed.connect(_on_pronoun_button_pressed.bind(button))

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
	verb_label.text = current_verb["name"]
	previous_score_label.text = "You got " + str(previous_score) + " wrong on the last problem"
	
	# Reset selection state
	selected_pronoun = ""
	selected_conjugation = ""
	previous_score = 0
	
	# Clear and regenerate conjugation buttons
	clear_conjugation_buttons()
	generate_conjugation_buttons()
	
	# Reset pronoun button states
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
	if selected_pronoun != "":
		# Check if this is a correct match
		var conjugation = button.text
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
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_conjugation = button.text

func clear_selections():
	# Clear pronoun button selections
	for button in pronoun_container.get_children():
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
	for button in pronoun_container.get_children():
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
