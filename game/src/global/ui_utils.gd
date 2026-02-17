extends Node

# Visual feedback for wrong answer
func flash_button_red_for_error(button: Button):
	button.modulate = Color.RED
	await get_tree().create_timer(0.5).timeout
	button.modulate = Color.WHITE
