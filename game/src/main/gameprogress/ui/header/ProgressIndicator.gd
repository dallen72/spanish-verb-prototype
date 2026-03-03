extends Control

# UI references
@onready var verb_ending_label: Label = %VerbEndingLabel
@onready var game_progress = Global.get_node("GameProgressMaster")
@onready var total_mistakes_label = %TotalMistakesLabel


func _ready():
	game_progress.total_mistakes.changed.connect(_update_error_label)

	
# Public methods for updating progress display
func update_progress():
	var current_verb: Verb = game_progress.get_current_verb()
	#var completed_verbs = game_progress.get_verbs_completed_for_excercise()
		
	# Update verb ending (first)
	verb_ending_label.text = "Ending: -" + (current_verb.ending if current_verb else "")

		
func _update_error_label(value):
	total_mistakes_label.text = "Total Mistakes: " + str(value)
