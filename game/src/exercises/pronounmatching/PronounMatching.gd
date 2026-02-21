extends Control

# UI Adapter for Pronoun Matching Game
# This class handles UI presentation and delegates game logic to PronounMatchSession

# Domain model - contains all game logic
@onready var session = $SessionState

var UIUtils = Global.get_node("UIUtils")


func _ready():		
	# Setup initial problem (conjugations need to load immediately)
	$SessionState.setup_initial_problem()

	$UIManager.initialize_pronoun_buttons()

	"""Connects domain model signals to UI update methods."""
	session.pronoun_selected.connect($UIManager.on_session_pronoun_selected)
	session.match_made.connect(_on_session_match_made)
	session.match_failed.connect(_on_session_match_failed)
	session.session_started.connect(_on_session_started)
		
	

func initialize(exercise: Exercise):
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
	
	$UIManager.set_label_text(exercise.label_text_for_given)
	
	# Reset pronoun buttons with the correct game mode
	$UIManager.reset_pronoun_buttons(current_verb, exercise)
	
	# Start new session
	session.start_problem(current_verb, exercise)




func setup_problem():
	"""Sets up a new problem (called by Main when starting new problem)."""
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = game_progress.get_current_verb()
		
	# Clear and regenerate conjugation buttons
	$UIManager.clear_conjugation_buttons()
	$UIManager.generate_conjugation_buttons(current_verb, _on_conjugation_button_pressed)
	
	# Reset pronoun buttons
	$UIManager.reset_pronoun_buttons(current_verb, game_progress.current_exercise)
	
	# Start new session
	if session:
		session.start_problem(current_verb, game_progress.current_exercise)
	
	$UIManager.post_problem_setup_processing(session.selected_pronoun)
	
# ===== UI Update Methods (called by domain model signals) =====

#	"""Called when a new session starts."""
func _on_session_started(exercise: Exercise):
	var game_progress = Global.get_node("GameProgressMaster")
	game_progress.current_exercise = exercise
	$UIManager.set_label_text(exercise.label_text_for_given)


func _on_session_match_made(pronoun: String, conjugation: String, english_phrase: String):
	"""Updates UI when a match is made in the domain model."""
	var pronoun_button = $UIManager.pronoun_buttons.get(pronoun)
	var conjugation_button = $UIManager.conjugation_buttons.get(conjugation)
	
	if pronoun_button and pronoun_button is PronounButton:
		# Update pronoun button to completed state
		pronoun_button.set_state(PronounButton.ButtonState.COMPLETED)
		pronoun_button.update_text_for_match(conjugation, session.exercise.name, english_phrase)
	
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
