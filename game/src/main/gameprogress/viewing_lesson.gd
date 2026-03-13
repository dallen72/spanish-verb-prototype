extends State

@onready var game_progress = Global.get_node("GameProgressMaster")
@onready var signals = Global.get_node("Signals")

func enter():
	game_progress.load_lesson_in_queue() # TODO: await when the load lesson uses await
	%UIManager.show_progress_screen()
	%UIManager.show_lesson()
	
func on_game_continue_button_pressed():
	%UIManager.end_lesson()
	Transitioned.emit(self, "ViewingProgress")
	Global.get_node("Signals").hide_intro_screen.emit()	
