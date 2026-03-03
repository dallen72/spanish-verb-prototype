extends State

@onready var game_progress = Global.get_node("GameProgressMaster")
@onready var signals = Global.get_node("Signals")

func enter():
	await get_tree().create_timer(Global.UI_TRANSITION_SLIDE_DURATION).timeout
	signals.start_problem.emit()

func on_problem_completed():
	%UIManager.remove_exercise_if_exists()
	Transitioned.emit(self, "UpdatingProgress")
