extends Node

const WIDTH_WHEN_EXERCISE_BUTTONS_WRAP: int = 1764
const TITLE_SECTION_SEPARATION_FOR_SMALL_SCREENS: int = 4

# Shared button colors (for conjugation and pronoun buttons)
var conjugation_button_bg_color: Color = Color(0.2, 0.2, 0.2, 0.8)
var conjugation_button_font_color: Color = Color(0.8, 0.8, 0.8, 1.0)
var conjugation_button_colors_initialized: bool = false

@onready var game_progress = Global.get_node("GameProgressMaster")

# UI references
@onready var verb_label: Label = $HeaderContainer/HBoxContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/HBoxContainer/TitleSection/PreviousScoreLabel
@onready var exercise_selector: HFlowContainer = $HeaderContainer/HBoxContainer/TitleSection/GameModeSelector
@onready var progress_indicator: Control = $HeaderContainer/HBoxContainer/ProgressIndicator
@onready var progress_screen: Control = $ProgressScreen
@onready var title_section: VBoxContainer = %TitleSection
@onready var exercise_container: HBoxContainer = %ExerciseContainer

var PronounMatching = preload("res://src/exercises/pronounmatching/PronounMatching.tscn")
var SentenceCompletion = preload("res://src/exercises/sentencecompletion/SentenceCompletion.tscn")


func _ready():
	exercise_selector.exercise_changed.connect(_on_exercise_changed)
	init_ui()

func show_initial_progress_and_start():
	# Show intro/progress screen; wait for user to click Continue (slide-out then signal)
	progress_screen.show_progress_screen()
	# Update UI
	previous_score_label.text = "You got " + str(game_progress.previous_score) + " wrong on the last problem"
	update_exercise_display()
	
	progress_indicator.update_progress()

	await progress_screen.progress_screen_closed


func _on_exercise_changed(mode: String):
	remove_exercise_if_exists()
	setup_problem(mode)


func init_ui():
	var window_size = DisplayServer.window_get_size()
	print_debug("debug, window_size: " + str(window_size))
	if (window_size.x < WIDTH_WHEN_EXERCISE_BUTTONS_WRAP):
		# get the theme property separation of the titlesection and set the theme override to 4
		title_section.add_theme_constant_override("separation", TITLE_SECTION_SEPARATION_FOR_SMALL_SCREENS)
	# Note: Viewport sizing is handled by Godot's stretch system in project settings
	# Do NOT manually resize the viewport - let Godot scale the game automatically
	# See project.godot: stretch mode = "canvas_items", aspect = "keep"

		# Initialize shared button colors when the game loads
	_init_conjugation_button_colors()

func _init_conjugation_button_colors():
	if conjugation_button_colors_initialized:
		return

	# Use the default theme as the source for button colors
	var theme := ThemeDB.get_default_theme()
	if theme:
		# Background color used by buttons (often the \"brown\" shade)
		if theme.has_color("bg_disabled_color", "Button"):
			conjugation_button_bg_color = theme.get_color("bg_disabled_color", "Button")
		elif theme.has_color("bg_color", "Button"):
			conjugation_button_bg_color = theme.get_color("bg_color", "Button")

		# Font color used by buttons
		if theme.has_color("font_color", "Button"):
			conjugation_button_font_color = theme.get_color("font_color", "Button")

	conjugation_button_colors_initialized = true

func get_conjugation_button_colors() -> Dictionary:
	"""
	Returns the shared conjugation/pronoun button colors.
	These are initialized once when the game loads so all buttons stay consistent.
	"""
	if not conjugation_button_colors_initialized:
		_init_conjugation_button_colors()

	return {
		"bg_color": conjugation_button_bg_color,
		"font_color": conjugation_button_font_color,
	}

func set_conjugation_button_colors(bg_color: Color, font_color: Color) -> void:
	"""
	Optional override: if we ever want to change button colors at runtime.
	"""
	conjugation_button_bg_color = bg_color
	conjugation_button_font_color = font_color
	conjugation_button_colors_initialized = true

func update_exercise_display():
	var current_verb: Verb = Global.get_node("GameProgressMaster").get_current_verb()
	var verb_name: String = current_verb.name if current_verb else ""
	if game_progress.current_exercise != null:
		if game_progress.current_exercise.name == "english_pronoun_matching":
			verb_label.text = "Match the English pronoun with the Spanish conjugation for " + verb_name
		elif game_progress.current_exercise.name == "spanish_pronoun_matching":
			verb_label.text = "Match the Spanish pronoun with the Spanish conjugation for " + verb_name
		elif game_progress.current_exercise.name == "sentence_completion":
			verb_label.text = "Match the conjugation with the correct sentence for " + verb_name


func show_progress_screen():
	progress_screen.show_progress_screen()
	await progress_screen.progress_screen_closed

# Notify child scenes to setup their problem
func setup_problem(mode: String = Global.initial_exercise.name):
	var exercise_node: Node
	# Show/hide child scenes based on game mode
	if mode == "sentence_completion":
		exercise_node = SentenceCompletion.instantiate()
		exercise_container.add_child(exercise_node)
		game_progress.current_exercise = game_progress.get_exercise_where_name_is("sentence_completion")
	else:
		exercise_node = PronounMatching.instantiate()
		exercise_container.add_child(exercise_node)
		
		if mode == "english_pronouns":
			game_progress.current_exercise = game_progress.get_exercise_where_name_is("english_pronoun_matching")
		else:
			game_progress.current_exercise = game_progress.get_exercise_where_name_is("spanish_pronoun_matching")
	
	update_exercise_display()
	game_progress.init_new_problem()
	exercise_node.setup_problem()
	
func remove_exercise_if_exists():
	if (exercise_container.get_child_count() > 0):
		var child = exercise_container.get_child(0)
		exercise_container.remove_child(child)
	
