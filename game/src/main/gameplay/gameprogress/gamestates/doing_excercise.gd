extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	%UIManager.setup_problem()


func on_problem_completed():
	Transitioned.emit(self, "UpdatingProgress")
