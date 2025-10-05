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

# Verb data is now imported from VerbData.gd

# UI references
@onready var verb_label: Label = $HeaderContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/TitleSection/PreviousScoreLabel
@onready var game_mode_selector: HBoxContainer = $HeaderContainer/TitleSection/GameModeSelector
@onready var progress_indicator: Control = $HeaderContainer/ProgressIndicator
@onready var pronoun_container: GridContainer = $VBoxContainer/GameArea/PronounSection/PronounGrid
@onready var english_container: GridContainer = $VBoxContainer/GameArea/EnglishSection/EnglishGrid
@onready var conjugation_container: GridContainer = $VBoxContainer/GameArea/ConjugationSection/ConjugationGrid
@onready var popup: Control = $Popup
@onready var popup_label: Label = $Popup/VBoxContainer/Label

func _ready():
	# Initialize the game with a random verb
	start_new_problem()
	
	# Connect game mode selector signal
	game_mode_selector.game_mode_changed.connect(_on_game_mode_changed)
	
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
	current_verb = VerbData.get_random_available_verb(completed_verbs)
	
	# If all verbs completed, reset and start over
	if completed_verbs.size() >= VerbData.get_total_verb_count():
		completed_verbs.clear()
		current_verb = VerbData.get_random_verb()
	
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
	progress_indicator.update_progress(current_verb, completed_verbs, total_errors)

func _on_game_mode_changed(mode: String):
	game_mode = mode
	
	if mode == "sentence_completion":
		get_tree().change_scene_to_file("res://SentenceCompletion.tscn")
	else:
		update_game_mode_display()
		start_new_problem()

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
