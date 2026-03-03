extends State

#TODO: find a way to inject into all the state scripts
@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	%UIManager.show_intro()
	
func on_continue_button_pressed():
	Transitioned.emit(self, "ViewingProgress")
	Global.get_node("Signals").hide_intro_screen.emit()	
