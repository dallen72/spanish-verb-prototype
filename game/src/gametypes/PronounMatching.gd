extends VBoxContainer

# Game state variables for pronoun matching
var selected_pronoun: String = ""
var selected_conjugation: String = ""
var selected_english_phrase: String = ""
var game_mode: String = "english_pronouns"  # "english_pronouns" or "spanish_pronouns"

# Reference to currently selected pronoun button
var selected_pronoun_button: PronounButton = null

# UI references
@onready var pronoun_section: VBoxContainer = $MarginContainer/GameArea/PronounSection
@onready var pronoun_label: Label = $MarginContainer/GameArea/PronounSection/PronounLabel
@onready var pronoun_container: GridContainer = $MarginContainer/GameArea/PronounSection/PronounMarginContainer/PronounGrid
@onready var conjugation_container: GridContainer = $MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer/ConjugationGrid
@onready var conjugation_margin_container: MarginContainer = $MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer

# Reference to main script for shared functionality
var main_script: Node = null

# Glow effect
var glow_effect: Node = null

# Track if first pronoun has been selected
var first_pronoun_selected: bool = false

func _ready():
	# Get reference to main script (PronounMatching is a child of Main)
	main_script = get_parent()
	
	# Convert existing pronoun buttons to PronounButton instances
	convert_pronoun_buttons()
	
	# Pronoun buttons will be disabled by their state machine
	# No need to disable them here - the state machine handles it
	
	# Create glow effect handler
	glow_effect = Node.new()
	glow_effect.set_script(load("res://src/ui/GlowEffect.gd"))
	add_child(glow_effect)
	
	# Setup initial problem (conjugations need to load immediately)
	setup_initial_problem()
	
	# Setup glow effects (after conjugations are loaded)
	call_deferred("setup_glow_effects")
	
	# Select first pronoun by default (only once on initial load)
	if not first_pronoun_selected:
		call_deferred("select_first_pronoun")

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

func setup_initial_problem():
	"""Sets up the initial problem when the scene loads."""
	# Ensure we have a game mode (default to english_pronouns)
	if game_mode == "":
		game_mode = "english_pronouns"
	
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
	
	# Update label text based on game mode
	if game_mode == "english_pronouns":
		pronoun_label.text = "English Pronouns"
	else:  # spanish_pronouns
		pronoun_label.text = "Spanish Pronouns"
	
	# Setup the problem
	setup_problem()

func setup_problem():
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# Clear and regenerate conjugation buttons
	clear_conjugation_buttons()
	generate_conjugation_buttons(current_verb)
	
	# Reset button states based on game mode
	reset_pronoun_buttons(current_verb)
	
	# Reset selection state
	selected_pronoun = ""
	selected_pronoun_button = null
	selected_conjugation = ""
	selected_english_phrase = ""
	first_pronoun_selected = false
	
	# Update glow effects after conjugations are loaded (deferred to ensure layout is complete)
	call_deferred("setup_glow_effects")
	
	# Select first pronoun for the new problem
	call_deferred("select_first_pronoun")

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
	
	# Set conjugation button reference for all pronoun buttons
	# Use the first conjugation button as reference
	if conjugation_values.size() > 0:
		var first_conjugation_button = conjugation_values[0]["button"]
		call_deferred("_set_all_pronoun_button_color_references", first_conjugation_button)

func convert_pronoun_buttons():
	"""Converts existing Button nodes to PronounButton instances."""
	var buttons_to_convert = []
	
	# Collect all buttons with their indices to preserve order
	for i in range(pronoun_container.get_child_count()):
		var button = pronoun_container.get_child(i)
		if button is Button and not button is PronounButton:
			buttons_to_convert.append({"button": button, "index": i})
	
	# Convert each button (in reverse order to preserve indices)
	buttons_to_convert.reverse()
	for item in buttons_to_convert:
		var old_button = item["button"]
		var index = item["index"]
		var pronoun_name = old_button.name
		var button_text = old_button.text
		var custom_min_size = old_button.custom_minimum_size
		var font_size = old_button.get_theme_font_size("font_size")
		
		# Remove old button
		pronoun_container.remove_child(old_button)
		old_button.queue_free()
		
		# Create new PronounButton
		var new_button = PronounButton.new()
		new_button.name = pronoun_name
		new_button.text = button_text
		new_button.custom_minimum_size = custom_min_size
		new_button.add_theme_font_size_override("font_size", font_size)
		new_button.pronoun_name = pronoun_name
		
		# Add to container at the same index to preserve order
		pronoun_container.add_child(new_button)
		pronoun_container.move_child(new_button, index)
	
	# Set color references for all pronoun buttons if conjugation buttons exist
	if conjugation_container.get_child_count() > 0:
		var first_conjugation = conjugation_container.get_child(0)
		if first_conjugation is Button:
			call_deferred("_set_all_pronoun_button_color_references", first_conjugation)

func reset_pronoun_buttons(current_verb: Dictionary):
	"""Resets all pronoun buttons to unmatched state."""
	for button in pronoun_container.get_children():
		if button is PronounButton:
			button.set_state(PronounButton.State.UNMATCHED)
			button.disabled = true  # Keep disabled - users don't click pronouns
			var pronoun = button.name
			if game_mode == "english_pronouns":
				# Use English phrases
				button.text = current_verb["english_phrases"][pronoun] + "..."
			else:  # spanish_pronouns
				# Use Spanish pronouns
				button.text = pronoun + "..."

func select_pronoun(pronoun_name: String):
	"""Selects a pronoun automatically (not from user click)."""
	var button = get_pronoun_button_by_name(pronoun_name)
	
	if not button or not button is PronounButton:
		return
	
	# Clear previous pronoun selection (but keep conjugation selection)
	if selected_pronoun_button and selected_pronoun_button.is_selected():
		selected_pronoun_button.set_state(PronounButton.State.UNMATCHED)
	
	# Set the selected pronoun
	button.set_state(PronounButton.State.SELECTED)
	selected_pronoun_button = button
	selected_pronoun = pronoun_name
	if game_mode == "english_pronouns":
		var game_progress = Global.get_node("GameProgressMaster")
		var current_verb = game_progress.get_current_verb()
		selected_english_phrase = current_verb["english_phrases"][pronoun_name]
	
	# Update glow effect to follow the selected pronoun
	update_glow_for_selected_pronoun()

func _on_pronoun_button_pressed(button: Button):
	# This function is no longer used since users don't click pronouns
	# But kept for compatibility - pronouns are selected automatically
	pass

func _on_conjugation_button_pressed(button: Button):
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	var conjugation = button.text
	
	# If conjugation button is already matched, ignore clicks
	if button.disabled:
		return
	
	# If we have a selected pronoun, check for a match
	if selected_pronoun != "" and selected_pronoun_button:
		# Check if this is a correct match
		if current_verb["conjugations"][selected_pronoun] == conjugation:
			# Correct match!
			show_match(selected_pronoun_button, button)
			
			# Clear conjugation selection
			selected_conjugation = ""
			clear_conjugation_selections()
			
			if all_are_matched():
				# All matches complete
				selected_pronoun = ""
				selected_pronoun_button = null
				selected_english_phrase = ""
				main_script.on_problem_completed()
			else:
				# Select the next pronoun automatically
				# Clear current selection first
				selected_pronoun = ""
				selected_pronoun_button = null
				selected_english_phrase = ""
				# Then select next (this will set selected_pronoun and selected_pronoun_button)
				# Use call_deferred to ensure state is updated before selecting next
				call_deferred("select_next_pronoun")
			return
		else:
			# Incorrect match
			main_script.on_error()
			# Clear conjugation selection but keep pronoun selected
			button.modulate = Color.WHITE
			selected_conjugation = ""
			return
	
	# No pronoun selected yet, just select this conjugation
	clear_conjugation_selections()
	button.modulate = Color.GREEN
	selected_conjugation = button.text

func clear_selections():
	"""Clears all selections (pronouns and conjugations)."""
	clear_pronoun_selections()
	clear_conjugation_selections()

func clear_pronoun_selections():
	"""Clears only pronoun button selections (resets selected to unmatched)."""
	for button in pronoun_container.get_children():
		if button is PronounButton and button.is_selected():
			# Reset selected buttons to unmatched (but keep completed ones)
			button.set_state(PronounButton.State.UNMATCHED)

func clear_conjugation_selections():
	"""Clears only conjugation button selections."""
	for button in conjugation_container.get_children():
		if button is Button:
			button.modulate = Color.WHITE

func show_match(pronoun_button: PronounButton, conjugation_button: Button):
	"""Marks a match as completed."""
	# Update pronoun button to completed state
	pronoun_button.set_state(PronounButton.State.COMPLETED)
	
	# Get conjugation text and update pronoun button text
	var conjugation_text = conjugation_button.text
	var english_phrase = ""
	if game_mode == "english_pronouns":
		var game_progress = Global.get_node("GameProgressMaster")
		var current_verb = game_progress.get_current_verb()
		english_phrase = current_verb["english_phrases"][pronoun_button.pronoun_name]
	
	pronoun_button.update_text_for_match(conjugation_text, game_mode, english_phrase)
	
	# Mark conjugation button as matched
	conjugation_button.modulate = Color.LIGHT_BLUE
	conjugation_button.disabled = true

func all_are_matched() -> bool:
	var matched_count = 0
	
	for button in pronoun_container.get_children():
		if button is PronounButton and button.is_completed():
			matched_count += 1
	return matched_count >= 6

func get_conjugation_button_by_text(text: String) -> Button:
	for button in conjugation_container.get_children():
		if button is Button and button.text == text:
			return button
	return null

func get_pronoun_button_by_name(button_name: String) -> PronounButton:
	for button in pronoun_container.get_children():
		if button is PronounButton and button.name == button_name:
			return button
	return null

func _set_pronoun_button_color_reference(pronoun_button: PronounButton):
	"""Sets the conjugation button reference for a pronoun button."""
	# Get the first conjugation button as reference
	if conjugation_container.get_child_count() > 0:
		var first_conjugation = conjugation_container.get_child(0)
		if first_conjugation is Button:
			pronoun_button.set_conjugation_button_reference(first_conjugation)
			# Update the state to apply the colors
			if pronoun_button.is_unmatched():
				pronoun_button.set_state(PronounButton.State.UNMATCHED)

func _set_all_pronoun_button_color_references(conjugation_button: Button):
	"""Sets the conjugation button reference for all pronoun buttons."""
	for button in pronoun_container.get_children():
		if button is PronounButton:
			button.set_conjugation_button_reference(conjugation_button)
			# Update the state to apply the colors
			if button.is_unmatched():
				button.set_state(PronounButton.State.UNMATCHED)

func setup_glow_effects():
	"""Sets up glow effects using the GlowEffect script."""
	if not glow_effect:
		return
	
	# Remove any existing glows
	glow_effect.remove_all_glows()
	
	# Create glow effect for currently selected pronoun (or first if none selected)
	var target_button = null
	if selected_pronoun_button:
		target_button = selected_pronoun_button
	elif selected_pronoun != "":
		target_button = get_pronoun_button_by_name(selected_pronoun)
	
	if not target_button:
		target_button = pronoun_container.get_child(0)
	
	if target_button is PronounButton:
		var button_parent = target_button.get_parent()
		glow_effect.add_glow_to_element(target_button, button_parent)
	
	# Create glow effect for ConjugationGrid
	var grid_parent = conjugation_container.get_parent()
	glow_effect.add_glow_to_element(conjugation_container, grid_parent)

func update_glow_for_selected_pronoun():
	"""Updates the glow effect to follow the currently selected pronoun."""
	if not glow_effect:
		return
	
	# Remove existing pronoun glow
	if glow_effect.glow_panels.size() > 0:
		# Remove the first glow (pronoun glow)
		var pronoun_glow = glow_effect.glow_panels[0]
		if is_instance_valid(pronoun_glow):
			pronoun_glow.queue_free()
		glow_effect.glow_panels.remove_at(0)
		if glow_effect.target_elements.size() > 0:
			glow_effect.target_elements.remove_at(0)
	
	# Add glow for currently selected pronoun
	if selected_pronoun_button:
		var button_parent = selected_pronoun_button.get_parent()
		glow_effect.add_glow_to_element(selected_pronoun_button, button_parent)
	elif selected_pronoun != "":
		var target_button = get_pronoun_button_by_name(selected_pronoun)
		if target_button is PronounButton:
			var button_parent = target_button.get_parent()
			glow_effect.add_glow_to_element(target_button, button_parent)

func select_first_pronoun():
	"""Selects the first pronoun button by default."""
	if first_pronoun_selected:
		return
	
	var first_button = pronoun_container.get_child(0)
	if first_button is PronounButton:
		# Select the first pronoun automatically
		select_pronoun(first_button.name)
		first_pronoun_selected = true

func select_next_pronoun():
	"""Selects the next unmatched pronoun in the list."""
	# Find the next pronoun that hasn't been matched yet
	for button in pronoun_container.get_children():
		if button is PronounButton:
			# Check if this pronoun is unmatched (not completed)
			if button.is_unmatched():
				# This pronoun hasn't been matched yet, select it
				select_pronoun(button.name)
				return
	
	# If we get here, all pronouns are matched (shouldn't happen, but handle it)
	selected_pronoun = ""
	selected_pronoun_button = null
	selected_conjugation = ""
	selected_english_phrase = ""
