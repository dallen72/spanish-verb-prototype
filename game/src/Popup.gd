extends Control

# UI references
@onready var popup_label: Label = $VBoxContainer/Label

# Signals for communicating with parent scenes
signal popup_closed

# Public methods for popup control
func show_popup(text: String = "Good Job!"):
	popup_label.text = text
	visible = true

func hide_popup():
	visible = false
	popup_closed.emit()

# Convenience method for showing popup with auto-hide timer
func show_popup_with_timer(text: String = "Good Job!", duration: float = 2.0):
	show_popup(text)
	await get_tree().create_timer(duration).timeout
	hide_popup()
