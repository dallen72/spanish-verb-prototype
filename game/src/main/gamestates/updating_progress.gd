extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	game_progress.add_completed_verb()
	Transitioned.emit(self, "ViewingProgress")
