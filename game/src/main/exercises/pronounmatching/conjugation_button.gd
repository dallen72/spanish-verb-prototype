class_name ConjugationButton
extends Button

var pronoun: String
var conjugation: String

@onready var game_progress = Global.get_node("GameProgressMaster")

func init_UI(_conjugation):
	text = _conjugation
	custom_minimum_size = Vector2(216, 108)
