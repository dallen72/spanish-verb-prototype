extends StateMachine

const ON_PROBLEM_COMPLETED = &"on_problem_completed"
const ON_CONTINUE_BUTTON_PRESSED = &"on_continue_button_pressed"

func _ready():
	super()
	Global.get_node("Signals").problem_completed.connect(_on_problem_completed)
	Global.get_node("Signals").continue_button_pressed.connect(_on_continue_button_pressed)


###########		State Machine Inputs	###########

func _on_continue_button_pressed():
	if current_state and current_state.has_method(ON_CONTINUE_BUTTON_PRESSED):
		current_state.call(ON_CONTINUE_BUTTON_PRESSED)

func _on_problem_completed():
	if current_state and current_state.has_method(ON_PROBLEM_COMPLETED):
		current_state.call(ON_PROBLEM_COMPLETED)
