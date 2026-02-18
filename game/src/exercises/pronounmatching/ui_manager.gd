extends Control

# UI references
@onready var margin_container = $VBoxContainer/MarginContainer
@onready var pronoun_section: VBoxContainer = $VBoxContainer/MarginContainer/GameArea/PronounSection
@onready var pronoun_label: Label = $VBoxContainer/MarginContainer/GameArea/PronounSection/PronounLabel
@onready var pronoun_container: FlowContainer = $VBoxContainer/MarginContainer/GameArea/PronounSection/PronounMarginContainer/PronounGrid
@onready var conjugation_container: GridContainer = $VBoxContainer/MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer/ConjugationGrid
@onready var conjugation_margin_container: MarginContainer = $VBoxContainer/MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer

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

	# Create glow effect handler
	glow_effect = GlowEffect.new()
	add_child(glow_effect)
	

func initialize_pronoun_buttons():
	"""Initializes references to pronoun buttons from the scene."""
	pronoun_buttons.clear()
	for button in pronoun_container.get_children():
		if button is PronounButton:
			button.pronoun_name = button.name
			pronoun_buttons[button.name] = button
	
			
func set_label_text(exercise_name):
		# Update label text based on game mode
	if exercise_name == "english_pronoun_matching":
		pronoun_label.text = "English Pronouns"
	else:  # spanish_pronouns
		pronoun_label.text = "Spanish Pronouns"


func on_session_pronoun_selected(pronoun: String):
	"""Updates UI when a pronoun is selected in the domain model."""
	var button = pronoun_buttons.get(pronoun)
	if not button or not button is PronounButton:
		return
	
	# Clear previous pronoun selection
	for btn in pronoun_buttons.values():
		if btn.is_selected():
			btn.set_state(PronounButton.ButtonState.UNMATCHED)
	
	# Set the selected pronoun
	button.set_state(PronounButton.ButtonState.SELECTED)
	
	# Update glow effect
	update_glow_for_selected_pronoun(pronoun)



func setup_glow_effects(selected_pronoun):
	"""Sets up glow effects using the GlowEffect script."""
	if not glow_effect:
		return
	
	# Remove any existing glows
	glow_effect.remove_all_glows()
	
	# Create glow effect for currently selected pronoun
	var target_button = pronoun_buttons.get(selected_pronoun)
	
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

#	"""Updates the glow effect to follow the currently selected pronoun."""
func update_glow_for_selected_pronoun(selected_pronoun):
	# Remove existing pronoun glow (first glow is always the pronoun)
	if glow_effect.glow_panels.size() > 0:
		var pronoun_glow = glow_effect.glow_panels[0]
		if is_instance_valid(pronoun_glow):
			pronoun_glow.queue_free()
		glow_effect.glow_panels.remove_at(0)
		if glow_effect.target_elements.size() > 0:
			glow_effect.target_elements.remove_at(0)
	
	# Add glow for currently selected pronoun
	var target_button = pronoun_buttons.get(selected_pronoun)
	if target_button and target_button is PronounButton:
		var button_parent = target_button.get_parent()
		if button_parent:
			glow_effect.add_glow_to_element(target_button, button_parent)



func clear_conjugation_buttons():
	"""Clears all conjugation buttons from the UI."""
	for child in conjugation_container.get_children():
		child.queue_free()
	conjugation_buttons.clear()


func clear_conjugation_selections():
	"""Clears visual selection feedback from conjugation buttons."""
	for button in conjugation_container.get_children():
		if button is Button and not button.disabled:
			button.modulate = Color.WHITE





func generate_conjugation_buttons(current_verb: Verb, button_callback: Callable):
	"""Generates conjugation buttons from verb data."""
	if current_verb == null or current_verb.conjugations.is_empty():
		return
	
	var conjugations = current_verb.conjugations
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
		
		button.pressed.connect(button_callback.bind(button))
		conjugation_values.append({"button": button, "conjugation": conjugation})
		conjugation_buttons[conjugation] = button
	
	# Shuffle the conjugations for random placement
	conjugation_values.shuffle()
	
	# Add buttons to the grid
	for item in conjugation_values:
		conjugation_container.add_child(item["button"])


func post_problem_setup_processing(selected_pronoun):
	# Update glow effects after conjugations are loaded
	call_deferred("setup_glow_effects", selected_pronoun)


func reset_pronoun_buttons(current_verb: Verb, exercise_value: String):
	"""Resets all pronoun buttons to unmatched state."""
	for pronoun_name in pronoun_buttons.keys():
		var button = pronoun_buttons[pronoun_name]
		if not button or not button is PronounButton:
			continue
		
		# TODO: search for "english_pronouns". no hardcoded
		if exercise_value == "english_pronoun_matching" and current_verb != null:
			# Use English phrases
			var phrase = current_verb.english_phrases.get(pronoun_name, "")
			button.text = phrase + "..." if phrase != "" else pronoun_name + "..."
		else:
			# Use Spanish pronouns
			button.text = pronoun_name + "..."
		
		# Set state to unmatched
		button.set_state(PronounButton.ButtonState.UNMATCHED)
