extends Control

# Signals for communicating with parent scenes
signal progress_screen_closed

# Margins and content size (30px margins, 1860 = 1920 - 60)
const MARGIN := 30
const CONTENT_WIDTH := 1860
const CONTENT_HEIGHT := 1020
const SLIDE_DURATION := 0.35
# Max width for each button and icon (1920/8)
const ROW_ITEM_SIZE := 240
const COMPLETED_ICON_MODULATE := Color(0.2, 0.8, 0.3, 1.0)

# UI references
var sliding_panel: Control
var buttons_column: VBoxContainer
var icons_column: VBoxContainer
var continue_button: Button

func _ready():
	sliding_panel = $SlidingPanel
	buttons_column = $SlidingPanel/VBoxContainer/ScrollContainer/CenterContainer/FlowContainer/ButtonsColumn
	icons_column = $SlidingPanel/VBoxContainer/ScrollContainer/CenterContainer/FlowContainer/IconsColumn
	continue_button = $SlidingPanel/VBoxContainer/ContinueButton
	continue_button.pressed.connect(_on_continue_pressed)
	_build_verb_list()

func _build_verb_list():
	for child in buttons_column.get_children():
		child.queue_free()
	for child in icons_column.get_children():
		child.queue_free()

	var game_progress = Global.get_node("GameProgressMaster")

	for verb_data in VerbData.VERB_LIST:
		var verb_name: String = verb_data["name"]
		for excercise in ExerciseData.EXERCISE_LIST:
			var completed_verbs = game_progress.get_completed_verbs(excercise["excercise_name"])
			var is_completed: bool = verb_name in completed_verbs

			# Button showing verb name
			var btn = Button.new()
			btn.text = verb_name
			btn.custom_minimum_size = Vector2(ROW_ITEM_SIZE, 40)
			btn.flat = false
			buttons_column.add_child(btn)

			# Icon when completed, or same-size spacer when not (keeps rows aligned)
			var icon_size = Vector2(ROW_ITEM_SIZE, 40)
			if is_completed:
				var tex_rect = TextureRect.new()
				tex_rect.custom_minimum_size = icon_size
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				var icon_path = excercise.icon_path
				var tex = load(icon_path) as Texture2D
				if tex:
					tex_rect.texture = tex
				tex_rect.modulate = COMPLETED_ICON_MODULATE
				icons_column.add_child(tex_rect)
			else:
				var spacer = Control.new()
				spacer.custom_minimum_size = icon_size
				icons_column.add_child(spacer)

func _on_continue_pressed():
	# Slide panel to the left off screen
	var tween = create_tween()
	tween.tween_property(sliding_panel, "position:x", -CONTENT_WIDTH, SLIDE_DURATION).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_slide_finished)

func _on_slide_finished():
	visible = false
	_reset_panel_position()
	progress_screen_closed.emit()

func _reset_panel_position():
	sliding_panel.position = Vector2(MARGIN, MARGIN)

func show_progress_screen():
	_reset_panel_position()
	_build_verb_list()
	visible = true
	# Start off-screen left, then slide in
	sliding_panel.position.x = -CONTENT_WIDTH
	var tween = create_tween()
	tween.tween_property(sliding_panel, "position:x", MARGIN, SLIDE_DURATION).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func hide_progress_screen():
	visible = false
	_reset_panel_position()
	progress_screen_closed.emit()

func show_progress_screen_with_timer(duration: float = 3.0):
	show_progress_screen()
	await get_tree().create_timer(duration).timeout
	hide_progress_screen()
