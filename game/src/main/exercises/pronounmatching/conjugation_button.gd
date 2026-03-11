class_name ConjugationButton
extends Button

var pronoun: String
var conjugation: String
var current_state: ResponsiveValue
var UIUtils = Global.get_node("UIUtils")

const BUTTON_CUSTOM_MIN_SIZE_X = 300
const BUTTON_CUSTOM_MIN_SIZE_Y = 150

enum ButtonState {
	UNSELECTED,
	ERRORED
}

@onready var game_progress = Global.get_node("GameProgressMaster")

func _ready():
	custom_minimum_size = Vector2(BUTTON_CUSTOM_MIN_SIZE_X, BUTTON_CUSTOM_MIN_SIZE_Y)
	current_state = ResponsiveValue.new(ButtonState.UNSELECTED)
	current_state.changed.connect(update_ui)


func update_ui(new_state: ButtonState):
	if new_state == ButtonState.ERRORED:
		UIUtils.flash_button_red_for_error(self)
		current_state.value = ButtonState.UNSELECTED
		
