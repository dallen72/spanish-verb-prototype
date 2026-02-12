extends StateMachine

const ON_PROBLEM_COMPLETED = &"on_problem_completed"
const ON_CONTINUE_BUTTON_PRESSED = &"on_continue_button_pressed"

func _ready():
	super()
	Global.get_node("Signals").problem_completed.connect(_on_problem_completed)
	Global.get_node("Signals").continue_button_pressed.connect(_on_continue_button_pressed)

func _on_continue_button_pressed():
	if current_state and current_state.has_method(ON_CONTINUE_BUTTON_PRESSED):
		current_state.call(ON_CONTINUE_BUTTON_PRESSED)

func _on_problem_completed():
	if current_state and current_state.has_method(ON_PROBLEM_COMPLETED):
		current_state.call(ON_PROBLEM_COMPLETED)

# init: move to loading game data
#
# loading game data: todo: load from save.
# initialize verbs, excercises
# calculate progress. TODO: load progress from save
# when game data loaded, go to viewing progress
#
# viewing progress: if not visible, visible is true.
# if not first_time_showing_progress, move_into_view_from_right 
# when continue pressed, go to doing next excercise
# exit: move_out_of_view_to_left
#
# doing_exercise:
# run exercise_loop
# when exercise_completed: go to updating progress
# when exercise button is clicked to switch: go to switching exercise 
#
# updating progress:
# calculate progress
# when done, go to viewing progress
#
# switching exercise:
# load exercise
# when done loading, go to doing exercise

#zone
#phase
#token
#resource
#asset
#agent
#condition

#state init
#state loading
#state matching
#state matched
#state completed

# state loading
# init vars
# go to matching state

#state matching:
#if the sentence button is clicked and it matches the pronoun
#	state transition to matched
#if the sentence button is clicked and it doesn't match
#	increase error count

# state matched:
# change colors of sentence buttons
# if continue button is clicked: transition to exit state

# exit state:
# emit complete_exercise signal
# transition to init state
