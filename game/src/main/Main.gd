extends Control

@onready var game_progress = Global.get_node("GameProgressMaster")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.is_debug_build():
			get_tree().quit()
