extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	Transitioned.emit(self, "viewingprogress")
