extends VBoxContainer

# Game state variables for pronoun matching
var selected_pronoun: String = ""
var selected_conjugation: String = ""
var selected_english_phrase: String = ""
var game_mode: String = "english_pronouns"  # "english_pronouns" or "spanish_pronouns"

# UI references
@onready var pronoun_section: VBoxContainer = $GameArea/PronounSection
@onready var english_section: VBoxContainer = $GameArea/EnglishSection
@onready var pronoun_container: GridContainer = $GameArea/PronounSection/PronounGrid
@onready var english_container: GridContainer = $GameArea/EnglishSection/EnglishGrid
@onready var conjugation_container: GridContainer = $GameArea/ConjugationSection/ConjugationGrid

# Reference to main script for shared functionality
var main_script: Node = null

func _ready():
	# Get reference to main script (PronounMatching is a child of Main)
	main_script = get_parent()
	
	# Set initial visibility based on default game mode
	if game_mode == "english_pronouns":
		english_section.visible = true
		pronoun_section.visible = false
	else:  # spanish_pronouns
		english_section.visible = false
		pronoun_section.visible = true
	
	# Connect pronoun button signals
	for button in pronoun_container.get_children():
		if button is Button:
			button.pressed.connect(_on_pronoun_button_pressed.bind(button))
	
	# Connect English phrase button signals
	for button in english_container.get_children():
		if button is Button:
			button.pressed.connect(_on_english_button_pressed.bind(button))

func initialize(game_mode_value: String):
	game_mode = game_mode_value
	
	# Toggle visibility of sections based on game mode
	if game_mode == "english_pronouns":
		english_section.visible = true
		pronoun_section.visible = false
	else:  # spanish_pronouns
		english_section.visible = false
		pronoun_section.visible = true
	
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
	if game_mode == "english_pronouns":
		reset_english_buttons(current_verb)
	else:  # spanish_pronouns
		reset_pronoun_buttons()

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
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	if selected_conjugation != "":
		# Check if this is a correct match
		var pronoun = button.name
		if current_verb["conjugations"][pronoun] == selected_conjugation:
			# Correct match!
			show_match(button, get_conjugation_button_by_text(selected_conjugation))
			if all_are_matched():
				main_script.on_problem_completed()
			selected_pronoun = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			main_script.on_error()
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_pronoun = button.name

func _on_conjugation_button_pressed(button: Button):
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	var conjugation = button.text
	
	if game_mode == "spanish_pronouns" and selected_pronoun != "":
		# Check if this is a correct match
		if current_verb["conjugations"][selected_pronoun] == conjugation:
			# Correct match!
			show_match(get_pronoun_button_by_name(selected_pronoun), button)
			if all_are_matched():
				main_script.on_problem_completed()
			selected_pronoun = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			main_script.on_error()
	elif game_mode == "english_pronouns" and selected_english_phrase != "":
		# Check if this is a correct match
		if current_verb["conjugations"][selected_english_phrase] == conjugation:
			# Correct match!
			show_match(get_english_button_by_pronoun(selected_english_phrase), button)
			if all_are_matched():
				main_script.on_problem_completed()
			selected_english_phrase = ""
			selected_conjugation = ""
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

func _on_english_button_pressed(button: Button):
	if game_mode != "english_pronouns":
		return
	
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	if selected_conjugation != "":
		# Check if this is a correct match
		var pronoun = button.name.replace("_eng", "")
		if current_verb["conjugations"][pronoun] == selected_conjugation:
			# Correct match!
			show_match(button, get_conjugation_button_by_text(selected_conjugation))
			if all_are_matched():
				main_script.on_problem_completed()
			selected_english_phrase = ""
			selected_conjugation = ""
			return
		else:
			# Incorrect match
			main_script.on_error()
	
	# Update selection
	clear_selections()
	button.modulate = Color.GREEN
	selected_english_phrase = button.name.replace("_eng", "")

func reset_english_buttons(current_verb: Dictionary):
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
