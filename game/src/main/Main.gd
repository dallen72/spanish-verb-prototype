extends Control

# TODO: get from an enum
var initial_exercise: String = "english_pronouns"  # "english_pronouns", "spanish_pronouns", or "sentence_completion"

@onready var game_progress = Global.get_node("GameProgressMaster")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.is_debug_build():
			get_tree().quit()

	
func _ready():
	%UIManager.init_ui()


func on_wrong_selection():
	# Called when an error is made
	game_progress.set_previous_score(game_progress.get_previous_score() + 1)
	game_progress.increment_total_errors()
	%UIManager.update_progress_indicator()
