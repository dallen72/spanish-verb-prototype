extends State


func enter():
	Transitioned.emit(self, "loadinggamedata")
