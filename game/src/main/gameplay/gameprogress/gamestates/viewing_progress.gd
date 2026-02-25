extends State

#TODO: find a way to inject into all the state scripts
@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	%UIManager.show_initial_progress_and_start()
	
func on_continue_button_pressed():
	Transitioned.emit(self, "DoingExercise")
	Global.get_node("Signals").hide_progress_screen.emit()	
