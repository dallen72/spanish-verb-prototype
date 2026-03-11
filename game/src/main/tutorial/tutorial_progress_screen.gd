extends "res://src/main/gameprogress/progress_screen.gd"


#TODO: attach event dispatchers for "tutorial_continued" to buttons, and
#TODO: add ui modifiers to the state machine for modifying the UI during the correct states

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

@onready var signals = Global.get_node("Signals")

# UI references
@onready var sliding_panel: Control = %SlidingPanel
@onready var title_label: Label = %TitleLabel
@onready var continue_button: Button = %ContinueButton
var VerbListWrapper: VBoxContainer


var continue_state_index_counter: int = 0

func _ready():
	signals.tutorial_continued.connect(update_progress_screen) # TODO: do we even need this signal to exist?
	main_tutorial_button.pressed.connect(update_progress_screen)	


func show_progress_screen():
	%UIManager.show_progress_screen()
	update_progress_screen()

enum TUTORIAL_STATE {
	SHOWING_FIRST_MESSAGE,
	SHOWING_SECOND_MESSAGE,
	SHOWING_FIRST_LESSON,
	SHOWING_SECOND_LESSON,
	ENDING_TUTORIAL
}

const FIRST_LESSON_NAME = "Tener"
const SECOND_LESSON_NAME = "English Pronoun Matching"

## TODO: why are there two continue buttons?  this is confusing
func update_progress_screen():
	if showing_lesson:
		continue_lesson()
		return

	match continue_state_index_counter:
		TUTORIAL_STATE.SHOWING_FIRST_MESSAGE:
			title_label.hide()
			main_text_label.show()
			main_text_label.text = "Hello!
I'm learning Spanish,
but I keep forgeting basic conjugations.
Can you relate?"
			continue_button.text = "Yes!"
		TUTORIAL_STATE.SHOWING_SECOND_MESSAGE:
			main_text_label.text = "Let's make sure we know Spanish conjugations!"
			continue_button.text = "Vamos !"
		TUTORIAL_STATE.SHOWING_FIRST_LESSON:
			continue_button.hide()
			start_lesson_with_name(FIRST_LESSON_NAME)
		TUTORIAL_STATE.SHOWING_SECOND_LESSON:
			start_lesson_with_name(SECOND_LESSON_NAME)
		TUTORIAL_STATE.ENDING_TUTORIAL:
			button_flash_tween.kill()
			signals.emit_signal("tutorial_finished")
	continue_state_index_counter += 1


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
