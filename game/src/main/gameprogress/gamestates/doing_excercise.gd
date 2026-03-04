extends State

@onready var game_progress = Global.get_node("GameProgressMaster")
@onready var signals = Global.get_node("Signals")

func enter():
	await signals.menu_screens_have_exited_the_screen
	%UIManager.remove_progress_screen()
	%UIManager.setup_problem()
	

func on_problem_completed():
	%UIManager.remove_exercise_if_exists()
	Transitioned.emit(self, "UpdatingProgress")
