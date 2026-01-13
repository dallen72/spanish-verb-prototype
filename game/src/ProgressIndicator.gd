extends Control

# UI references
@onready var verb_ending_label: Label = $VBoxContainer/VerbEndingLabel
@onready var current_verb_label: Label = $VBoxContainer/CurrentVerbLabel
@onready var total_errors_label: Label = $VBoxContainer/TotalErrorsLabel
@onready var verbs_completed_label: Label = $VBoxContainer/VerbsCompletedLabel

# Public methods for updating progress display
func update_progress(current_verb: Dictionary, completed_verbs: Array, total_errors: int):
	# Update verb ending (first)
	verb_ending_label.text = "Ending: -" + current_verb["ending"]
	
	# Update current verb
	current_verb_label.text = "current verb: " + current_verb["name"]
	
	# Update total errors
	total_errors_label.text = "Total Errors: " + str(total_errors)
	
	# Update verbs completed
	var total_verbs = VerbData.get_total_verb_count()
	var completed_count = completed_verbs.size()
	
	verbs_completed_label.text = "Completed: " + str(completed_count) + "/" + str(total_verbs)
