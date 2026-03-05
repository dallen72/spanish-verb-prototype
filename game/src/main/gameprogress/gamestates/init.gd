extends State


func enter():
	Transitioned.emit(self, "LoadingGameData")
