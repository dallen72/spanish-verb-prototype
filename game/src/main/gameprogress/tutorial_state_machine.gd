extends StateMachine

const ON_TUTORIAL_CONTINUED = &"on_tutorial_continued"


func _ready():
	super()
	Global.get_node("Signals").continue_button_pressed.connect(_on_continue_button_pressed)

###########		State Machine Inputs	###########

func _on_continue_button_pressed():
	if current_state and current_state.has_method(ON_TUTORIAL_CONTINUED):
		current_state.call(ON_TUTORIAL_CONTINUED)
