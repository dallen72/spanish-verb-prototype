extends VBoxContainer

# UI Adapter for Pronoun Matching Game
# This class handles UI presentation and delegates game logic to PronounMatchSession

# Domain model - contains all game logic
var session: PronounMatchManager = null

# UI references
@onready var margin_container = $MarginContainer
@onready var pronoun_section: VBoxContainer = $MarginContainer/GameArea/PronounSection
@onready var pronoun_label: Label = $MarginContainer/GameArea/PronounSection/PronounLabel
@onready var pronoun_container: FlowContainer = $MarginContainer/GameArea/PronounSection/PronounMarginContainer/PronounGrid
@onready var conjugation_container: GridContainer = $MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer/ConjugationGrid
@onready var conjugation_margin_container: MarginContainer = $MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer

# Glow effect handler
var glow_effect: GlowEffect = null

# Track pronoun button references for UI updates
var pronoun_buttons: Dictionary = {}  # pronoun_name -> PronounButton
var conjugation_buttons: Dictionary = {}  # conjugation_text -> Button

func _ready():
	var window_size = DisplayServer.window_get_size()
	print_debug("debug, window_size: " + str(window_size))
	if (window_size.x < 1764):		
		print_debug("debug, window is smaller, inside pronoun script")
		# get the theme property separation of the titlesection and set the theme override to 4
		pronoun_container.add_theme_constant_override("margin_left", 0)
		pronoun_container.add_theme_constant_override("margin_right", 0)
		pronoun_container.add_theme_constant_override("margin_top", 0)
		pronoun_container.add_theme_constant_override("margin_bottom", 0)
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_right", 0)
		margin_container.add_theme_constant_override("margin_top", 0)
		margin_container.add_theme_constant_override("margin_bottom", 0)
	
	# Create domain model session
	session = PronounMatchManager.new()
	_connect_session_signals()
	
	# Create glow effect handler
	glow_effect = GlowEffect.new()
	add_child(glow_effect)
	
	# Initialize pronoun button references
	_initialize_pronoun_buttons()
	
	# Setup initial problem (conjugations need to load immediately)
	setup_initial_problem()
	
	# Setup glow effects (after conjugations are loaded)
	call_deferred("setup_glow_effects")

func _connect_session_signals():
	"""Connects domain model signals to UI update methods."""
	session.pronoun_selected.connect(_on_session_pronoun_selected)
	session.match_made.connect(_on_session_match_made)
	session.match_failed.connect(_on_session_match_failed)
	session.session_started.connect(_on_session_started)

func _initialize_pronoun_buttons():
	"""Initializes references to pronoun buttons from the scene."""
	pronoun_buttons.clear()
	for button in pronoun_container.get_children():
		if button is PronounButton:
			button.pronoun_name = button.name
			pronoun_buttons[button.name] = button

func initialize(game_mode_value: String):
	"""Initializes the game with a specific game mode."""
	if not session:
		return
	
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# If current_verb is empty, set it now
	if current_verb.is_empty():
		current_verb = game_progress.get_random_available_verb()
		if game_progress.get_completed_verbs().size() >= VerbData.get_total_verb_count():
			game_progress.clear_completed_verbs()
			current_verb = VerbData.get_random_verb()
		game_progress.set_current_verb(current_verb)
	
	# Update label text based on game mode
	if game_mode_value == "english_pronouns":
		pronoun_label.text = "English Pronouns"
	else:  # spanish_pronouns
		pronoun_label.text = "Spanish Pronouns"
	
	# Reset pronoun buttons with the correct game mode
	reset_pronoun_buttons(current_verb, game_mode_value)
	
	# Start new session
	session.start_problem(current_verb, game_mode_value)

func setup_initial_problem():
	"""Sets up the initial problem when the scene loads."""
	# Ensure we have a game mode (default to english_pronouns)
	var game_mode_value = "english_pronouns"
	
	# Ensure current_verb is set
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# If current_verb is empty, set it now
	if current_verb.is_empty():
		current_verb = game_progress.get_random_available_verb()
	
	# Update label text based on game mode
	if game_mode_value == "english_pronouns":
		pronoun_label.text = "English Pronouns"
	else:  # spanish_pronouns
		pronoun_label.text = "Spanish Pronouns"
	
	# Reset pronoun buttons with the correct game mode
	reset_pronoun_buttons(current_verb, game_mode_value)
	
	# Start session
	if session:
		session.start_problem(current_verb, game_mode_value)

func setup_problem():
	"""Sets up a new problem (called by Main when starting new problem)."""
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# Determine game mode (use existing session mode or default)
	var game_mode_value = "english_pronouns"
	if session and session.game_mode != "":
		game_mode_value = session.game_mode
	
	# Clear and regenerate conjugation buttons
	clear_conjugation_buttons()
	generate_conjugation_buttons(current_verb)
	
	# Reset pronoun buttons
	reset_pronoun_buttons(current_verb, game_mode_value)
	
	# Start new session
	if session:
		session.start_problem(current_verb, game_mode_value)
	
	# Update glow effects after conjugations are loaded
	call_deferred("setup_glow_effects")

# ===== UI Update Methods (called by domain model signals) =====

func _on_session_started(game_mode_value: String):
	var game_progress = Global.get_node("GameProgressMaster")
	"""Called when a new session starts."""
	# Update label text
	if game_mode_value == "english_pronouns":
		pronoun_label.text = "English Pronouns"
		game_progress.current_excercise = "english_pronoun_matching"
	else:
		pronoun_label.text = "Spanish Pronouns"
		game_progress.current_excercise = "spanish_pronoun_matching"


func _on_session_pronoun_selected(pronoun: String):
	"""Updates UI when a pronoun is selected in the domain model."""
	var button = pronoun_buttons.get(pronoun)
	if not button or not button is PronounButton:
		return
	
	# Clear previous pronoun selection
	for btn in pronoun_buttons.values():
		if btn.is_selected():
			btn.set_state(PronounButton.State.UNMATCHED)
	
	# Set the selected pronoun
	button.set_state(PronounButton.State.SELECTED)
	
	# Update glow effect
	update_glow_for_selected_pronoun()

func _on_session_match_made(pronoun: String, conjugation: String, english_phrase: String):
	"""Updates UI when a match is made in the domain model."""
	var pronoun_button = pronoun_buttons.get(pronoun)
	var conjugation_button = conjugation_buttons.get(conjugation)
	
	if pronoun_button and pronoun_button is PronounButton:
		# Update pronoun button to completed state
		pronoun_button.set_state(PronounButton.State.COMPLETED)
		pronoun_button.update_text_for_match(conjugation, session.game_mode, english_phrase)
	
	if conjugation_button:
		# Mark conjugation button as matched
		conjugation_button.modulate = Color.LIGHT_BLUE
		conjugation_button.disabled = true

func _on_session_match_failed():
	"""Handles UI feedback when a match fails."""
	# Notify main script of error
	Global.get_node("Signals").emit_signal("wrong_selection")
	
	# Clear conjugation selection visual feedback
	clear_conjugation_selections()

# ===== UI Helper Methods =====

func clear_conjugation_buttons():
	"""Clears all conjugation buttons from the UI."""
	for child in conjugation_container.get_children():
		child.queue_free()
	conjugation_buttons.clear()

func generate_conjugation_buttons(current_verb: Dictionary):
	"""Generates conjugation buttons from verb data."""
	if not current_verb.has("conjugations"):
		return
	
	var conjugations = current_verb["conjugations"]
	var conjugation_values = []
	
	# Create buttons for each conjugation
	for pronoun in conjugations.keys():
		var conjugation = conjugations[pronoun]
		var button = Button.new()
		button.text = conjugation
		button.custom_minimum_size = Vector2(216, 108)
		button.add_theme_font_size_override("font_size", 30)
		
		# Apply shared colors from Global
		if Engine.has_singleton("Global"):
			var root = Engine.get_singleton("Global")
			if root and root.has_node("GameProgressMaster"):
				var gp = root.get_node("GameProgressMaster")
				if gp and gp.has_method("get_conjugation_button_colors"):
					var colors = gp.get_conjugation_button_colors()
					if colors.has("bg_color"):
						var style := StyleBoxFlat.new()
						style.bg_color = colors["bg_color"]
						style.corner_radius_top_left = 4
						style.corner_radius_top_right = 4
						style.corner_radius_bottom_left = 4
						style.corner_radius_bottom_right = 4
						button.add_theme_stylebox_override("normal", style)
					if colors.has("font_color"):
						button.add_theme_color_override("font_color", colors["font_color"])
		
		button.pressed.connect(_on_conjugation_button_pressed.bind(button))
		conjugation_values.append({"button": button, "conjugation": conjugation})
		conjugation_buttons[conjugation] = button
	
	# Shuffle the conjugations for random placement
	conjugation_values.shuffle()
	
	# Add buttons to the grid
	for item in conjugation_values:
		conjugation_container.add_child(item["button"])

func reset_pronoun_buttons(current_verb: Dictionary, game_mode_value: String):
	"""Resets all pronoun buttons to unmatched state."""
	for pronoun_name in pronoun_buttons.keys():
		var button = pronoun_buttons[pronoun_name]
		if not button or not button is PronounButton:
			continue
		
		if game_mode_value == "english_pronouns":
			# Use English phrases
			var english_phrases = current_verb.get("english_phrases", {})
			if english_phrases is Dictionary:
				var phrase = english_phrases.get(pronoun_name, "")
				button.text = phrase + "..." if phrase != "" else pronoun_name + "..."
		else:  # spanish_pronouns
			# Use Spanish pronouns
			button.text = pronoun_name + "..."
		
		# Set state to unmatched
		button.set_state(PronounButton.State.UNMATCHED)

func _on_conjugation_button_pressed(button: Button):
	"""Handles conjugation button clicks - forwards to domain model."""
	if not session:
		return
	
	# If conjugation button is already matched, ignore clicks
	if button.disabled:
		return
	
	var conjugation = button.text
	
	# Forward match attempt to domain model
	session.attempt_match(conjugation)
	
	# If no pronoun is selected, just highlight the conjugation
	if session.selected_pronoun.is_empty():
		clear_conjugation_selections()
		button.modulate = Color.GREEN

func clear_conjugation_selections():
	"""Clears visual selection feedback from conjugation buttons."""
	for button in conjugation_container.get_children():
		if button is Button and not button.disabled:
			button.modulate = Color.WHITE

# ===== Glow Effect Methods =====

func setup_glow_effects():
	"""Sets up glow effects using the GlowEffect script."""
	if not glow_effect:
		return
	
	# Remove any existing glows
	glow_effect.remove_all_glows()
	
	# Create glow effect for currently selected pronoun
	var target_button = null
	if session and not session.selected_pronoun.is_empty():
		target_button = pronoun_buttons.get(session.selected_pronoun)
	
	if not target_button:
		# Fallback to first button
		target_button = pronoun_container.get_child(0)
	
	if target_button and target_button is PronounButton:
		var button_parent = target_button.get_parent()
		if button_parent:
			glow_effect.add_glow_to_element(target_button, button_parent)
	
	# Create glow effect for ConjugationGrid
	var grid_parent = conjugation_container.get_parent()
	if grid_parent:
		glow_effect.add_glow_to_element(conjugation_container, grid_parent)

func update_glow_for_selected_pronoun():
	"""Updates the glow effect to follow the currently selected pronoun."""
	if not glow_effect or not session:
		return
	
	# Remove existing pronoun glow (first glow is always the pronoun)
	if glow_effect.glow_panels.size() > 0:
		var pronoun_glow = glow_effect.glow_panels[0]
		if is_instance_valid(pronoun_glow):
			pronoun_glow.queue_free()
		glow_effect.glow_panels.remove_at(0)
		if glow_effect.target_elements.size() > 0:
			glow_effect.target_elements.remove_at(0)
	
	# Add glow for currently selected pronoun
	if not session.selected_pronoun.is_empty():
		var target_button = pronoun_buttons.get(session.selected_pronoun)
		if target_button and target_button is PronounButton:
			var button_parent = target_button.get_parent()
			if button_parent:
				glow_effect.add_glow_to_element(target_button, button_parent)
