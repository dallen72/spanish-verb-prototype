extends Control

# Game state variables
var game_mode: String = "english_pronouns"  # "english_pronouns", "spanish_pronouns", or "sentence_completion"

# Verb data is now imported from VerbData.gd

# UI references
@onready var verb_label: Label = $HeaderContainer/HBoxContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/HBoxContainer/TitleSection/PreviousScoreLabel
@onready var game_mode_selector: HFlowContainer = $HeaderContainer/HBoxContainer/TitleSection/GameModeSelector
@onready var progress_indicator: Control = $HeaderContainer/HBoxContainer/ProgressIndicator
@onready var popup: Control = $Popup
@onready var progress_screen: Control = $ProgressScreen
@onready var title_section: VBoxContainer = %TitleSection

# Child scene references
@onready var pronoun_matching: VBoxContainer = %PronounMatching
@onready var sentence_completion: VBoxContainer = %SentenceCompletion

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.is_debug_build():
			get_tree().quit()

const WINDOW_SCRIPT := preload("res://WindowScript.gd")

func _ready():
	var window_size = DisplayServer.window_get_size()
	print("debug, window_size: " + str(window_size))
	if (window_size.x < 1764):		
		# get the theme property separation of the titlesection and set the theme override to 4
		title_section.add_theme_constant_override("separation", 4)

	
	# Connect game mode selector signal
	game_mode_selector.game_mode_changed.connect(_on_game_mode_changed)

	# Note: Viewport sizing is handled by Godot's stretch system in project settings
	# Do NOT manually resize the viewport - let Godot scale the game automatically
	# See project.godot: stretch mode = "canvas_items", aspect = "keep"

	# Initialize the game on startup - show progress screen first
	call_deferred("_show_initial_progress_and_start")

func _show_initial_progress_and_start():
	# Show intro/progress screen; wait for user to click Continue (slide-out then signal)
	progress_screen.show_progress_screen()
	start_new_problem()
	await progress_screen.progress_screen_closed

func start_new_problem():
	# Select a random verb that hasn't been completed yet
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb = VerbData.get_random_available_verb(game_progress.get_completed_verbs())
	
	# If all verbs completed, reset and start over
	if game_progress.get_completed_verbs().size() >= VerbData.get_total_verb_count():
		game_progress.clear_completed_verbs()
		current_verb = VerbData.get_random_verb()
	
	# Set the current verb in GameProgressMaster
	game_progress.set_current_verb(current_verb)
	
	# Update UI
	previous_score_label.text = "You got " + str(game_progress.get_previous_score()) + " wrong on the last problem"
	update_game_mode_display()
	
	# Reset previous score for next problem
	game_progress.reset_previous_score()
	
	# Update progress indicator
	update_progress_indicator()
	
	# Notify child scenes to setup their problem
	if pronoun_matching and pronoun_matching.has_method("setup_problem"):
		pronoun_matching.setup_problem()
	if sentence_completion and sentence_completion.has_method("setup_problem"):
		sentence_completion.setup_problem()

func update_progress_indicator():
	var game_progress = Global.get_node("GameProgressMaster")
	progress_indicator.update_progress(game_progress.get_current_verb(), game_progress.get_completed_verbs(), game_progress.get_total_errors())

func _on_game_mode_changed(mode: String):
	game_mode = mode
	
	# Show/hide child scenes based on game mode
	if mode == "sentence_completion":
		pronoun_matching.visible = false
		sentence_completion.visible = true
	else:
		pronoun_matching.visible = true
		sentence_completion.visible = false
		# Initialize pronoun matching with the correct game mode
		if pronoun_matching.has_method("initialize"):
			pronoun_matching.initialize(mode)
	
	update_game_mode_display()
	start_new_problem()

func update_game_mode_display():
	var current_verb = Global.get_node("GameProgressMaster").get_current_verb()
	if game_mode == "english_pronouns":
		verb_label.text = "Match the English pronoun with the Spanish conjugation for " + current_verb["name"]
	elif game_mode == "spanish_pronouns":
		verb_label.text = "Match the Spanish pronoun with the Spanish conjugation for " + current_verb["name"]
	elif game_mode == "sentence_completion":
		verb_label.text = "Match the conjugation with the correct sentence for " + current_verb["name"]

# Public methods for child scenes to use
func on_problem_completed():
	# Called when a problem is completed
	var game_progress = Global.get_node("GameProgressMaster")
	game_progress.add_completed_verb(game_progress.get_current_verb()["name"])

	# Show progress screen (slides in from left); wait for user to click Continue
	progress_screen.show_progress_screen()
	await progress_screen.progress_screen_closed

	# Start next problem
	start_new_problem()

func on_error():
	# Called when an error is made
	var game_progress = Global.get_node("GameProgressMaster")
	game_progress.set_previous_score(game_progress.get_previous_score() + 1)
	game_progress.increment_total_errors()
	update_progress_indicator()

func show_popup():
	popup.show_popup()

func hide_popup():
	popup.hide_popup()
