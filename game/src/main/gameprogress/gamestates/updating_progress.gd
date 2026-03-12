extends State

@onready var game_progress = Global.get_node("GameProgressMaster")

func enter():
	game_progress.update_verb_score_after_exercise()
	game_progress.determine_what_lessons_have_been_unlocked()
	if game_progress.name_of_lesson_in_queue != "":
		Transitioned.emit(self, "ViewingLesson")
	else:
		Transitioned.emit(self, "ViewingProgress")
