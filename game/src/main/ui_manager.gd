extends Node

const WIDTH_WHEN_EXERCISE_BUTTONS_WRAP: int = 1764
const TITLE_SECTION_SEPARATION_FOR_SMALL_SCREENS: int = 4

@onready var game_progress = Global.get_node("GameProgressMaster")

# UI references
@onready var verb_label: Label = $HeaderContainer/HBoxContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/HBoxContainer/TitleSection/PreviousScoreLabel
@onready var exercise_selector: HFlowContainer = $HeaderContainer/HBoxContainer/TitleSection/GameModeSelector
@onready var progress_indicator: Control = $HeaderContainer/HBoxContainer/ProgressIndicator
@onready var progress_screen: Control = $ProgressScreen
@onready var title_section: VBoxContainer = %TitleSection

# Child scene references
@onready var pronoun_matching: VBoxContainer = %PronounMatching
@onready var sentence_completion: VBoxContainer = %SentenceCompletion


func _ready():
	exercise_selector.exercise_changed.connect(_on_exercise_changed)


func show_initial_progress_and_start():
	# Show intro/progress screen; wait for user to click Continue (slide-out then signal)
	progress_screen.show_progress_screen()
	# Update UI
	previous_score_label.text = "You got " + str(game_progress.get_previous_score()) + " wrong on the last problem"
	update_exercise_display()
	
	# Update progress indicator
	%UIManager.update_progress_indicator()

	await progress_screen.progress_screen_closed


func _on_exercise_changed(mode: String):
	# Show/hide child scenes based on game mode
	if mode == "sentence_completion":
		pronoun_matching.visible = false
		sentence_completion.visible = true
		game_progress.current_exercise = game_progress.get_exercise("sentence_completion")
	else:
		pronoun_matching.visible = true
		sentence_completion.visible = false
		# Initialize pronoun matching with the correct game mode
		if pronoun_matching.has_method("initialize"):
			pronoun_matching.initialize(mode)
		
		## TODO: spanish or english based on what it is
		game_progress.current_exercise = game_progress.get_exercise("spanish_pronoun_matching")
	
	update_exercise_display()
	game_progress.init_new_problem()


func init_ui():
	var window_size = DisplayServer.window_get_size()
	print_debug("debug, window_size: " + str(window_size))
	if (window_size.x < WIDTH_WHEN_EXERCISE_BUTTONS_WRAP):
		# get the theme property separation of the titlesection and set the theme override to 4
		title_section.add_theme_constant_override("separation", TITLE_SECTION_SEPARATION_FOR_SMALL_SCREENS)
	# Note: Viewport sizing is handled by Godot's stretch system in project settings
	# Do NOT manually resize the viewport - let Godot scale the game automatically
	# See project.godot: stretch mode = "canvas_items", aspect = "keep"


func update_exercise_display():
	var current_verb = Global.get_node("GameProgressMaster").get_current_verb()
	if game_progress.current_exercise.name == "english_pronouns":
		verb_label.text = "Match the English pronoun with the Spanish conjugation for " + current_verb["name"]
	elif game_progress.current_exercise.name == "spanish_pronouns":
		verb_label.text = "Match the Spanish pronoun with the Spanish conjugation for " + current_verb["name"]
	elif game_progress.current_exercise.name == "sentence_completion":
		verb_label.text = "Match the conjugation with the correct sentence for " + current_verb["name"]


func update_progress_indicator():
	progress_indicator.update_progress()


func show_progress_screen():
	progress_screen.show_progress_screen()
	await progress_screen.progress_screen_closed


func setup_problem():
	# Notify child scenes to setup their problem
	if pronoun_matching and pronoun_matching.has_method("setup_problem"):
		pronoun_matching.setup_problem()
	if sentence_completion and sentence_completion.has_method("setup_problem"):
		sentence_completion.setup_problem()
