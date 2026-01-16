extends Control

# Game state variables
var game_mode: String = "english_pronouns"  # "english_pronouns", "spanish_pronouns", or "sentence_completion"

# Verb data is now imported from VerbData.gd

# UI references
@onready var verb_label: Label = $HeaderContainer/TitleSection/VerbLabel
@onready var previous_score_label: Label = $HeaderContainer/TitleSection/PreviousScoreLabel
@onready var game_mode_selector: HBoxContainer = $HeaderContainer/TitleSection/GameModeSelector
@onready var progress_indicator: Control = $HeaderContainer/ProgressIndicator
@onready var popup: Control = $Popup

# Child scene references
@onready var pronoun_matching: VBoxContainer = $PronounMatching
@onready var sentence_completion: VBoxContainer = $SentenceCompletion

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.is_debug_build():
			get_tree().quit()

func _ready():
	# For web builds, also listen for window resize events
	var is_web = OS.get_name() == "Web" or DisplayServer.get_name() == "web"
	if is_web:
		var window = get_window()
		#if window:
			# Connect to size_changed signal to handle browser window resizing
			#window.size_changed.connect(_on_window_size_changed)
	
	# Connect game mode selector signal
	game_mode_selector.game_mode_changed.connect(_on_game_mode_changed)
	
	# Adjust viewport size based on available screen/window size
	# For web builds, wait a frame to let Godot detect the canvas size automatically
	if is_web:
		# Wait for the next frame to let Godot automatically detect the canvas size
		await get_tree().process_frame
		# Now read the automatically detected size and apply our resolution selection
		adjust_viewport_size()
	else:
		# For desktop, can adjust immediately
		adjust_viewport_size()

func _on_window_size_changed():
	"""
	Called when the browser window is resized.
	Re-adjusts the viewport size to fit the new browser window size.
	"""
	var is_web = OS.get_name() == "Web" or DisplayServer.get_name() == "web"
	if is_web:
		# Wait a frame to ensure we get the accurate new canvas size
		await get_tree().process_frame
		adjust_viewport_size()

func adjust_viewport_size():
	"""
	Adjusts the viewport size to the largest 16:9 resolution that fits in the available screen/window.
	For web builds, uses the actual browser viewport size (excluding browser UI).
	For desktop builds, uses screen size.
	Resolutions checked (in order): 1920x1080, 1536x864, 1366x768, 1280x720
	"""
	var available_size: Vector2i
	var is_web = OS.get_name() == "Web" or DisplayServer.get_name() == "web"
	
	if is_web:
		# For web builds, use get_window().size which is what Godot uses internally
		# With canvasResizePolicy=2, Godot automatically adapts the canvas to the browser window
		# get_window().size returns the actual canvas size that Godot has set
		# This is the browser window size excluding browser UI (address bar, tabs, etc.)
		var window = get_window()
		if window:
			# Use window.size - this is what Godot sets based on the browser canvas
			available_size = window.size
			
			# Also try content_scale_size as a more accurate measure
			if available_size.x <= 0 or available_size.y <= 0:
				available_size = window.content_scale_size
		else:
			available_size = Vector2i(1280, 720)
		
		# Final fallback
		if available_size.x <= 0 or available_size.y <= 0:
			available_size = Vector2i(1280, 720)
	else:
		# For desktop builds, use screen size
		available_size = DisplayServer.screen_get_size()
	
	# List of 16:9 resolutions in descending order (largest first)
	var resolutions = [
		Vector2i(1920, 1080),
		Vector2i(1536, 864),
		Vector2i(1366, 768),
		Vector2i(1280, 720)
	]
	
	# Find the largest resolution that fits in the available space
	var selected_resolution = resolutions[resolutions.size() - 1]  # Default to smallest
	
	for resolution in resolutions:
		if resolution.x <= available_size.x and resolution.y <= available_size.y:
			selected_resolution = resolution
			break
	
	# Set the window/viewport size
	var window = get_window()
	var viewport = get_viewport()
	
	if window and viewport:
		if is_web:
			# For web builds with integer scaling, set viewport to match canvas size exactly
			# Integer scaling only scales UP by integer factors (1x, 2x, 3x)
			# If viewport is larger than canvas, it won't scale down and will be cropped
			# By matching canvas size, the viewport renders at 1x scale and fits perfectly
			# This ensures the game fits inside the viewport
			var canvas_size = window.size
			if canvas_size.x > 0 and canvas_size.y > 0:
				viewport.size = canvas_size
			else:
				# Fallback to selected resolution if canvas size not available
				viewport.size = selected_resolution
		else:
			# For desktop, set window size and center it
			window.size = selected_resolution
			var screen_size = DisplayServer.screen_get_size()
			var centered_position = (screen_size - selected_resolution) / 2
			window.position = centered_position
	
	print("Platform: ", "Web" if is_web else "Desktop")
	print("Available size: ", available_size.x, "x", available_size.y)
	print("Selected resolution: ", selected_resolution.x, "x", selected_resolution.y)
	if is_web and viewport:
		print("Actual viewport size: ", viewport.size.x, "x", viewport.size.y)
		print("Visible rect size: ", viewport.get_visible_rect().size.x, "x", viewport.get_visible_rect().size.y)

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
	show_popup()
	await get_tree().create_timer(2.0).timeout
	hide_popup()
	var game_progress = Global.get_node("GameProgressMaster")
	game_progress.add_completed_verb(game_progress.get_current_verb()["name"])
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
