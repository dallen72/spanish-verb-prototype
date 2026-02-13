extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	game_progress.current_exercise = Global.initial_exercise
	game_progress.init_new_problem()
	Transitioned.emit(self, "viewingprogress")
