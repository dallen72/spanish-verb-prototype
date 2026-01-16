extends VBoxContainer

# Game state variables for pronoun matching
var selected_pronoun: String = ""
var selected_conjugation: String = ""
var selected_english_phrase: String = ""
var game_mode: String = "english_pronouns"  # "english_pronouns" or "spanish_pronouns"

# UI references
@onready var pronoun_section: VBoxContainer = $MarginContainer/GameArea/PronounSection
@onready var pronoun_label: Label = $MarginContainer/GameArea/PronounSection/PronounLabel
@onready var pronoun_container: GridContainer = $MarginContainer/GameArea/PronounSection/PronounMarginContainer/PronounGrid
@onready var conjugation_container: GridContainer = $MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer/ConjugationGrid

# Reference to main script for shared functionality
var main_script: Node = null

func _ready():
	# Get reference to main script (PronounMatching is a child of Main)
	main_script = get_parent()
	
	# Connect pronoun button signals
	for button in pronoun_container.get_children():
		if button is Button:
			button.pressed.connect(_on_pronoun_button_pressed.bind(button))

func initialize(game_mode_value: String):
	game_mode = game_mode_value
	
	# Update label text based on game mode
	if game_mode == "english_pronouns":
		pronoun_label.text = "English Pronouns"
	else:  # spanish_pronouns
		pronoun_label.text = "Spanish Pronouns"
	
	# Ensure current_verb is set
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# If current_verb is empty, set it now
	if current_verb.is_empty():
		current_verb = VerbData.get_random_available_verb(game_progress.get_completed_verbs())
		if game_progress.get_completed_verbs().size() >= VerbData.get_total_verb_count():
			game_progress.clear_completed_verbs()
			current_verb = VerbData.get_random_verb()
		game_progress.set_current_verb(current_verb)
	
	# Now setup the problem
	setup_problem()

func setup_problem():
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# Clear and regenerate conjugation buttons
	clear_conjugation_buttons()
	generate_conjugation_buttons(current_verb)
	
	# Reset button states based on game mode
	reset_pronoun_buttons(current_verb)

func clear_conjugation_buttons():
	for child in conjugation_container.get_children():
		child.queue_free()

func generate_conjugation_buttons(current_verb: Dictionary):
	var conjugations = current_verb["conjugations"]
	var conjugation_values = []
	
	# Create buttons for each conjugation
	for pronoun in conjugations.keys():
		var conjugation = conjugations[pronoun]
		var button = Button.new()
		button.text = conjugation
		button.custom_minimum_size = Vector2(216, 108)
		button.add_theme_font_size_override("font_size", 30)
		button.pressed.connect(_on_conjugation_button_pressed.bind(button))
		conjugation_values.append({"button": button, "conjugation": conjugation, "pronoun": pronoun})
	
	# Shuffle the conjugations for random placement
	conjugation_values.shuffle()
	
	# Add buttons to the grid
	for item in conjugation_values:
		conjugation_container.add_child(item["button"])

func reset_pronoun_buttons(current_verb: Dictionary):
	for button in pronoun_container.get_children():
		if button is Button:
			button.disabled = false
			button.modulate = Color.WHITE
			var pronoun = button.name
			if game_mode == "english_pronouns":
				# Use English phrases
				button.text = current_verb["english_phrases"][pronoun] + "..."
			else:  # spanish_pronouns
				# Use Spanish pronouns
				button.text = pronoun + "..."

func _on_pronoun_button_pressed(button: Button):
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	var pronoun = button.name
	
	if selected_conjugation != "":
		# Check if this is a correct match
		if current_verb["conjugations"][pronoun] == selected_conjugation:
			# Correct match!
			show_match(button, get_conjugation_button_by_text(selected_conjugation))
			if all_are_matched():
				main_script.on_problem_completed()
			selected_pronoun = ""
			selected_conjugation = ""
			selected_english_phrase = ""
			return
		else:
			# Incorrect match
			main_script.on_error()
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_pronoun = pronoun
	if game_mode == "english_pronouns":
		selected_english_phrase = pronoun

func _on_conjugation_button_pressed(button: Button):
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	var conjugation = button.text
	
	if selected_pronoun != "":
		# Check if this is a correct match
		if current_verb["conjugations"][selected_pronoun] == conjugation:
			# Correct match!
			show_match(get_pronoun_button_by_name(selected_pronoun), button)
			if all_are_matched():
				main_script.on_problem_completed()
			selected_pronoun = ""
			selected_conjugation = ""
			selected_english_phrase = ""
			return
		else:
			# Incorrect match
			main_script.on_error()
	
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
	if game_mode == "english_pronouns":
		var game_progress = Global.get_node("GameProgressMaster")
		var current_verb = game_progress.get_current_verb()
		var pronoun = pronoun_button.name
		pronoun_button.text = current_verb["english_phrases"][pronoun] + " " + conjugation_button.text
	else:  # spanish_pronouns
		pronoun_button.text = pronoun_button.name + " " + conjugation_button.text

func all_are_matched() -> bool:
	var matched_count = 0
	
	for button in pronoun_container.get_children():
		if button is Button and button.disabled:
			matched_count += 1
	return matched_count >= 6

func get_conjugation_button_by_text(text: String) -> Button:
	for button in conjugation_container.get_children():
		if button is Button and button.text == text:
			return button
	return null

func get_pronoun_button_by_name(button_name: String) -> Button:
	for button in pronoun_container.get_children():
		if button is Button and button.name == button_name:
			return button
	return null
