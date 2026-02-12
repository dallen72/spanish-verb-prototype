extends Control

var initial_exercise: String = ExerciseDataAccess.get_exercise_list()[0].name

@onready var game_progress = Global.get_node("GameProgressMaster")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.is_debug_build():
			get_tree().quit()

	
func _ready():
	%UIManager.init_ui()
