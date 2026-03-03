extends State


func enter():
	%UIManager.show_first_verb()


func on_tutorial_continued():
	Transitioned.emit(self, "ShowingFirstExercise")
