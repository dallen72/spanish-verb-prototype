extends "res://src/main/gameprogress/ui_manager.gd"



func show_progress_screen():
	reset_panel_position()
		
	visible = true
	# Start off-screen left, then slide in
	sliding_panel.position.x = -CONTENT_WIDTH
	var tween = create_tween()
	tween.tween_property(sliding_panel, "position:x", MARGIN, SLIDE_DURATION).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	show_first_verb()


func show_first_verb():
	%ContinueButton.text = "debug"


func show_first_exercise():
	pass
	
	
func end_tutorial():
	pass
