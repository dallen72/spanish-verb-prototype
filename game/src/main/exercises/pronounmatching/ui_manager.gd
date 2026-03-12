extends Control

# UI references
@onready var margin_container = $VBoxContainer/MarginContainer
@onready var pronoun_section: VBoxContainer = $VBoxContainer/MarginContainer/GameArea/PronounSection
@onready var pronoun_label: Label = $VBoxContainer/MarginContainer/GameArea/PronounSection/PronounLabel
@onready var pronoun_container: Control = %PronounGrid
@onready var conjugation_container: GridContainer = $VBoxContainer/MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer/ConjugationGrid
@onready var conjugation_margin_container: MarginContainer = $VBoxContainer/MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer
@onready var game_progress = Global.get_node("GameProgressMaster")

# Glow effect handler
var glow_effect: GlowEffect = null

# Track pronoun button references for UI updates
var pronoun_buttons: Dictionary = {}  # pronoun_name -> PronounButton

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
			button.size.x = (get_parent().size.x - 20) / 2
			button.size.y = (get_parent().size.y - 20) / 3
			pronoun_buttons[button.name] = button
	
			
func set_label_text():
	pronoun_label.text = game_progress.current_exercise.label_text_for_given


## handler. Updates UI when a pronoun is selected
func update_pronoun_selection(pronoun: String):
	await get_tree().process_frame
	var button: PronounButton = pronoun_buttons.get(pronoun)
		
	for btn in pronoun_buttons.values():
		btn.set_correct_state_and_matched_if(button)
	
	# Update glow effect
	update_glow_for_selected_pronoun(pronoun)


func setup_glow_effects(selected_pronoun):
	"""Sets up glow effects using the GlowEffect script."""
	assert(glow_effect != null)
	
	glow_effect.remove_all_glows()
	
	# Create glow effect for currently selected pronoun
	var target_button: PronounButton = pronoun_buttons.get(selected_pronoun)
	if not target_button:
		# Fallback to first button
		target_button = pronoun_container.get_child(0)
	glow_effect.add_glow_to_element(target_button, target_button.get_parent())
	
	# Create glow effect for ConjugationGrid
	var grid_parent = conjugation_container.get_parent()
	if grid_parent:
		glow_effect.add_glow_to_element(conjugation_container, grid_parent)


##	"""Updates the glow effect to follow the currently selected pronoun."""
func update_glow_for_selected_pronoun(selected_pronoun):
	# Remove existing pronoun glow (first glow is always the pronoun)
	if glow_effect.glow_panels.size() > 0:
		glow_effect.remove_glow_at_nodes_with_name("Button")
	
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


## Clears visual selection feedback from conjugation buttons.
func clear_conjugation_selection_appearances():
	for button in conjugation_container.get_children():
		if button is Button and not button.disabled:
			button.modulate = Color.WHITE


func generate_conjugation_buttons(button_callback: Callable):
	var current_verb = game_progress.current_verb 
	if current_verb == null or current_verb.conjugations.is_empty():
		return
	
	var conjugation_button_list = []
	
	# Create buttons for each conjugation
	for pronoun in current_verb.conjugations.keys():
		var conjugation_button = ConjugationButton.new()		
		conjugation_button.text = current_verb.conjugations[pronoun]
		conjugation_button.pressed.connect(button_callback.bind(conjugation_button))
		conjugation_button.conjugation = current_verb.conjugations[pronoun]
		
		conjugation_button_list.append(conjugation_button)
	
	# Shuffle the conjugations for random placement and add them to the UI
	conjugation_button_list.shuffle()
	for button in conjugation_button_list:
		conjugation_container.add_child(button)


func setup_UI(selected_pronoun, callback):
	initialize_pronoun_buttons()
	generate_conjugation_buttons(callback)

	pronoun_container.visible = false
	# Update glow effects after conjugations are loaded
	call_deferred("setup_glow_effects", selected_pronoun)
	await get_tree().process_frame
	call_deferred("adjust_size_of_buttons_dynamically")
	pronoun_container.visible = true
		

func adjust_size_of_buttons_dynamically():
	if pronoun_container.size.x > pronoun_container.size.y:
		pronoun_container.columns = 3
	else:
		pronoun_container.columns = 2
	#for button in pronoun_container.get_children():
		#if button is PronounButton:
			#button.size.x = (pronoun_container.size.x - 20) / 2
			#button.size.y = (pronoun_container.size.y - 20) / 3
