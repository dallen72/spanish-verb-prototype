extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	# TODO: pass the number of mistakes that were made
	game_progress.update_verb_score(game_progress.current_verb, 1)
	Transitioned.emit(self, "ViewingProgress")
