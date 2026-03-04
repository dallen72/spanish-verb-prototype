extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	if Global.is_tutorial:
		Transitioned.emit(self, "viewingintro")
	else:
		Transitioned.emit(self, "vewingprogress")
