extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	game_progress.update_verb_score_after_exercise()
	Transitioned.emit(self, "ViewingProgress")
