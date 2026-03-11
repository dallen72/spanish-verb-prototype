extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	%UIManager.show_progress_screen()
	
func on_game_continue_button_pressed():
	Transitioned.emit(self, "DoingExercise")
	Global.get_node("Signals").hide_progress_screen.emit()	
 
