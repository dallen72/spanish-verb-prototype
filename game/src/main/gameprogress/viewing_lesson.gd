extends State

#TODO: find a way to inject into all the state scripts
@onready var game_progress = Global.get_node("GameProgressMaster")
@onready var signals = Global.get_node("Signals")

func enter():
	game_progress.load_lesson()
	await signals.lesson_loaded
	%UIManager.show_lesson()
	
func on_continue_button_pressed():
	Transitioned.emit(self, "ViewingProgress")
	Global.get_node("Signals").hide_intro_screen.emit()	
