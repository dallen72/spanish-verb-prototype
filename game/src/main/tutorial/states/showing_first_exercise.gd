extends State


func enter():
	%UIManager.show_first_exercise()


func on_tutorial_continued():
	Transitioned.emit(self, "ShowingProgressNormally")
