extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	game_progress.current_exercise = game_progress.game_exercises[0]
	game_progress.init_new_problem()
	Transitioned.emit(self, "viewingprogress")
