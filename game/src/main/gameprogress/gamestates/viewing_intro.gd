extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	%UIManager.update_scene_with_correct_progress_screen()
	%UIManager.start_intro()
	%UIManager.show_progress_screen()	
	
func on_tutorial_started():
	Global.get_node("Signals").hide_intro_screen.emit()	


func on_tutorial_finished():
	Global.get_node("Signals").hide_progress_screen.emit()
	Global.is_tutorial = false
	Transitioned.emit(self, "DoingExercise")
