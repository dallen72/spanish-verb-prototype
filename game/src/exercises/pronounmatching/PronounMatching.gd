extends Control

# UI Adapter for Pronoun Matching Game
# This class handles UI presentation and delegates game logic to PronounMatchSession

# Domain model - contains all game logic
@onready var session = $SessionState

var UIUtils = Global.get_node("UIUtils")


func _ready():	
	_connect_session_signals()
		
	# Initialize pronoun button references
	$UIManager.initialize_pronoun_buttons()
	
	# Setup initial problem (conjugations need to load immediately)
	setup_initial_problem()
	
	session.pronoun_selected.connect($UIManager.on_session_pronoun_selected)


func _connect_session_signals():
	"""Connects domain model signals to UI update methods."""
	session.match_made.connect(_on_session_match_made)
	session.match_failed.connect(_on_session_match_failed)
	session.session_started.connect(_on_session_started)


func initialize(exercise_value: String):
	"""Initializes the game with a specific game mode."""
	if not session:
		return
	
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# If current_verb is not set, set it now
	if current_verb == null:
		current_verb = game_progress.get_random_noncompleted_verb()
		if game_progress.get_completed_verbs().size() >= VerbDataAccess.get_total_verb_count():
			game_progress.clear_completed_verbs()
			current_verb = game_progress.get_random_verb()
		game_progress.set_current_verb(current_verb)
	
	$UIManager.set_label_text(exercise_value)
	
	# Reset pronoun buttons with the correct game mode
	reset_pronoun_buttons(current_verb, exercise_value)
	
	# Start new session
	session.start_problem(current_verb, exercise_value)


func setup_initial_problem():
	"""Sets up the initial problem when the scene loads."""
	# Ensure we have a game mode (default to english_pronouns)
	var exercise_value = "english_pronouns"
	
	# Ensure current_verb is set
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# If current_verb is not set, set it now
	if current_verb == null:
		current_verb = game_progress.get_next_verb()
	
	$UIManager.set_label_text(exercise_value)
	
	# Reset pronoun buttons with the correct game mode
	reset_pronoun_buttons(current_verb, exercise_value)
	
	# Start session
	if session:
		session.start_problem(current_verb, exercise_value)

func setup_problem():
	"""Sets up a new problem (called by Main when starting new problem)."""
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
	
	# Determine game mode (use existing session mode or default)
	var exercise_value = "english_pronouns"
	if session and session.exercise != "":
		exercise_value = session.exercise
	
	# Clear and regenerate conjugation buttons
	$UIManager.clear_conjugation_buttons()
	$UIManager.generate_conjugation_buttons(current_verb, _on_conjugation_button_pressed)
	
	# Reset pronoun buttons
	reset_pronoun_buttons(current_verb, exercise_value)
	
	# Start new session
	if session:
		session.start_problem(current_verb, exercise_value)
	
	$UIManager.post_problem_setup_processing(session.selected_pronoun)
	
# ===== UI Update Methods (called by domain model signals) =====

#	"""Called when a new session starts."""
func _on_session_started(exercise_value: String):
	var game_progress = Global.get_node("GameProgressMaster")

	$UIManager.set_label_text(exercise_value)

	# Update label text
	if exercise_value == "english_pronouns":
		game_progress.current_exercise = game_progress.get_exercise_where_name_is("english_pronoun_matching")
	else:
		game_progress.current_exercise = game_progress.get_exercise_where_name_is("spanish_pronoun_matching")


func _on_session_match_made(pronoun: String, conjugation: String, english_phrase: String):
	"""Updates UI when a match is made in the domain model."""
	var pronoun_button = $UIManager.pronoun_buttons.get(pronoun)
	var conjugation_button = $UIManager.conjugation_buttons.get(conjugation)
	
	if pronoun_button and pronoun_button is PronounButton:
		# Update pronoun button to completed state
		pronoun_button.set_state(PronounButton.ButtonState.COMPLETED)
		pronoun_button.update_text_for_match(conjugation, session.exercise, english_phrase)
	
	if conjugation_button:
		# Mark conjugation button as matched
		conjugation_button.modulate = Color.LIGHT_BLUE
		conjugation_button.disabled = true

func _on_session_match_failed():
	"""Handles UI feedback when a match fails."""
	# Notify main script of error
	Global.get_node("Signals").emit_signal("wrong_selection")
	
	# Clear conjugation selection visual feedback
	$UIManager.clear_conjugation_selections()

# ===== UI Helper Methods =====


func reset_pronoun_buttons(current_verb: Verb, exercise_value: String):
	"""Resets all pronoun buttons to unmatched state."""
	for pronoun_name in $UIManager.pronoun_buttons.keys():
		var button = $UIManager.pronoun_buttons[pronoun_name]
		if not button or not button is PronounButton:
			continue
		
		if exercise_value == "english_pronouns" and current_verb != null:
			# Use English phrases
			var phrase = current_verb.english_phrases.get(pronoun_name, "")
			button.text = phrase + "..." if phrase != "" else pronoun_name + "..."
		else:
			# Use Spanish pronouns
			button.text = pronoun_name + "..."
		
		# Set state to unmatched
		button.set_state(PronounButton.ButtonState.UNMATCHED)


func _on_conjugation_button_pressed(button: Button):
	"""Handles conjugation button clicks - forwards to domain model."""
	if not session:
		return
	
	# If conjugation button is already matched, ignore clicks
	if button.disabled:
		return
	
	var conjugation = button.text
	
	# Forward match attempt to domain model
	if not session.attempt_match(conjugation):
		UIUtils.flash_button_red_for_error(button)
	
	# If no pronoun is selected, just highlight the conjugation
	if session.selected_pronoun.is_empty():
		$UIManager.clear_conjugation_selections()
		button.modulate = Color.GREEN
