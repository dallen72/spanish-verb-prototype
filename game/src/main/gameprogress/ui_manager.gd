extends Control


# Margins and content size (30px margins, 1860 = 1920 - 60)
const MARGIN := 30
const CONTENT_WIDTH := 1860
const CONTENT_HEIGHT := 1020
const SLIDE_DURATION := Global.UI_TRANSITION_SLIDE_DURATION
# Max width for each button and icon (1920/8)
const ROW_ITEM_SIZE := 240
const COMPLETED_ICON_MODULATE := Color(0.2, 0.8, 0.3, 1.0)


# UI references
@onready var sliding_panel: Control = %SlidingPanel
@onready var game_continue_button: Button = %GameContinueButton
@onready var VerbListWrapper: VBoxContainer = %ListWrapper


func _ready():
	game_continue_button.pressed.connect(_on_continue_pressed)
	Global.get_node("Signals").hide_progress_screen.connect(hide_progress_screen)


func _on_continue_pressed():
	Global.get_node("Signals").emit_signal("game_continue_button_pressed")


func _build_verb_list():
	for child in VerbListWrapper.get_children():
		child.queue_free()
		
#	var game_progress = Global.get_node("GameProgressMaster")

	for verb_obj in VerbDataAccess.fetch_all_verbs():
		var verb_name: String = verb_obj.name
		var btn = Button.new()
		btn.text = verb_name
		btn.custom_minimum_size = Vector2(ROW_ITEM_SIZE, 40)
		btn.flat = false
		var flow_container = FlowContainer.new()
		flow_container.add_child(btn)

		var icons_column = Container.new()
		# add to UI
		#for excercise in ExerciseDataAccess.fetch_exercise_list():
			#var completed_verbs = game_progress.get_verbs_completed_for_excercise(excercise.name)
			#var is_completed: bool = verb_name in completed_verbs
#
			## Icon when completed, or same-size spacer when not (keeps rows aligned)
			#var icon_size = Vector2(ROW_ITEM_SIZE, 40)
			#if is_completed:
				#var tex_rect = TextureRect.new()
				#tex_rect.custom_minimum_size = icon_size
				#tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				#tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				#var icon_path = excercise.icon_path
				#var tex = load(icon_path) as Texture2D
				#if tex:
					#tex_rect.texture = tex
				#tex_rect.modulate = COMPLETED_ICON_MODULATE
				#icons_column.add_child(tex_rect)
				#
		if (icons_column != null):
			flow_container.add_child(icons_column)
		VerbListWrapper.add_child(flow_container)



func hide_progress_screen():
# Slide panel to the left off screen
	var tween = create_tween()
	tween.tween_property(sliding_panel, "position:x", -CONTENT_WIDTH, SLIDE_DURATION).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	visible = false
	Global.get_node("Signals").menu_screens_have_exited_the_screen.emit()


func reset_panel_position():
	sliding_panel.position = Vector2(MARGIN, MARGIN)


func show_progress_screen():
	reset_panel_position()
	_build_verb_list()
	visible = true
	# Start off-screen left, then slide in
	sliding_panel.position.x = -CONTENT_WIDTH
	var tween = create_tween()
	tween.tween_property(sliding_panel, "position:x", MARGIN, SLIDE_DURATION).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
