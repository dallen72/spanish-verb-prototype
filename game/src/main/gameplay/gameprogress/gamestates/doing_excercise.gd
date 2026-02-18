extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	%UIManager.setup_problem()


func on_problem_completed():
	%UIManager.remove_exercise_if_exists()
	Transitioned.emit(self, "UpdatingProgress")
