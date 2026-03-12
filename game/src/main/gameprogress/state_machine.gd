extends StateMachine

const ON_PROBLEM_COMPLETED = &"on_problem_completed"
const ON_game_continue_button_PRESSED = &"on_game_continue_button_pressed"
const ON_TUTORIAL_STARTED = &"on_tutorial_started"
const ON_TUTORIAL_FINISHED = &"on_tutorial_finished"

func _ready():
	super()
	Global.get_node("Signals").problem_completed.connect(_on_problem_completed)
	Global.get_node("Signals").game_continue_button_pressed.connect(_on_game_continue_button_pressed)
	Global.get_node("Signals").tutorial_started.connect(_on_tutorial_started)
	Global.get_node("Signals").tutorial_finished.connect(_on_tutorial_finished)

###########		State Machine Inputs	###########

func _on_game_continue_button_pressed():
	if current_state and current_state.has_method(ON_game_continue_button_PRESSED):
		current_state.call(ON_game_continue_button_PRESSED)

func _on_problem_completed():
	if current_state and current_state.has_method(ON_PROBLEM_COMPLETED):
		current_state.call(ON_PROBLEM_COMPLETED)

func _on_problem_started():
	%UIManager.setup_problem()

func _on_tutorial_started():
	if current_state and current_state.has_method(ON_TUTORIAL_STARTED):
		current_state.call(ON_TUTORIAL_STARTED)

func _on_tutorial_finished():
	if current_state and current_state.has_method(ON_TUTORIAL_FINISHED):
		current_state.call(ON_TUTORIAL_FINISHED)
