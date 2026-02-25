extends Control

# Signals for communicating with parent scenes
signal intro_screen_closed

# Margins and content size (30px margins, 1860 = 1920 - 60)
const MARGIN := 30
const CONTENT_WIDTH := 1860
const CONTENT_HEIGHT := 1020
const SLIDE_DURATION := Global.UI_TRANSITION_SLIDE_DURATION
# Max width for each button and icon (1920/8)
const ROW_ITEM_SIZE := 240
const COMPLETED_ICON_MODULATE := Color(0.2, 0.8, 0.3, 1.0)

# UI references
var sliding_panel: Control
var continue_button: Button
var VerbListWrapper: VBoxContainer
var main_text_label: Label

var continue_state_index_counter: int = 0

func _ready():
	sliding_panel = $SlidingPanel
	continue_button = $SlidingPanel/VBoxContainer/ContinueButton
	main_text_label = $SlidingPanel/VBoxContainer/MainText
	
	continue_button.pressed.connect(_on_continue_pressed)
	Global.get_node("Signals").hide_intro_screen.connect(hide_intro_screen)


# TODO: make the connect on line 24 connect to the global signal
func _on_continue_pressed():	
	continue_state_index_counter += 1
	match continue_state_index_counter:
		0:
			main_text_label.text = "Hello!
I'm learning Spanish,
but I keep forgeting basic conjugations.
Can you relate?"
			continue_button.text = "Yes!"
		1:
			main_text_label.text = "Let's make sure we know Spanish conjugations!"
			continue_button.text = "Vamos !"
		2:
			Global.get_node("Signals").emit_signal("continue_button_pressed")

func hide_intro_screen():
# Slide panel to the left off screen
	var tween = create_tween()
	tween.tween_property(sliding_panel, "position:x", -CONTENT_WIDTH, SLIDE_DURATION).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	visible = false
	_reset_panel_position()
	intro_screen_closed.emit()

func _reset_panel_position():
	sliding_panel.position = Vector2(MARGIN, MARGIN)

func show_intro_screen():
	_reset_panel_position()
	visible = true
