class_name ConjugationButton
extends Button

var pronoun: String
var conjugation: String
var current_state: ResponsiveValue

enum ButtonState {
	UNSELECTED,
	ERRORED
}

@onready var game_progress = Global.get_node("GameProgressMaster")

func _ready():
	custom_minimum_size = Vector2(216, 108)
	current_state = ResponsiveValue.new(ButtonState.UNSELECTED)
	current_state.changed.connect(update_ui)


func update_ui(new_state):
	if new_state.value == ButtonState.ERRORED:
		print("debug")
