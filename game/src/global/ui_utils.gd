extends Node

# Visual feedback for wrong answer
func flash_button_red_for_error(button: Button):
	button.modulate = Color.RED
	await get_tree().create_timer(0.5).timeout
	button.modulate = Color.WHITE


## flash node to show that it should be clicked
func flash_text_node(node: Node) -> Tween:
	var button_flash_tween = create_tween()
	var flash_duration = 1
	button_flash_tween.set_loops(0)
	button_flash_tween.tween_property(node, "modulate", Color.ORANGE, flash_duration)
	button_flash_tween.tween_property(node, "modulate", Color.BLACK, flash_duration)
	return button_flash_tween
