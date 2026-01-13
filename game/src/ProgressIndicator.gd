extends Control

# UI references
@onready var current_verb_label: Label = $VBoxContainer/ContentContainer/LeftColumn/CurrentVerbLabel
@onready var verbs_completed_label: Label = $VBoxContainer/ContentContainer/LeftColumn/VerbsCompletedLabel
@onready var verb_ending_label: Label = $VBoxContainer/ContentContainer/RightColumn/VerbEndingLabel
@onready var total_errors_label: Label = $VBoxContainer/ContentContainer/RightColumn/TotalErrorsLabel

# Public methods for updating progress display
func update_progress(current_verb: Dictionary, completed_verbs: Array, total_errors: int):
	# Update current verb
	current_verb_label.text = "Current: " + current_verb["name"]
	
	# Update verbs completed
	var total_verbs = VerbData.get_total_verb_count()
	var completed_count = completed_verbs.size()
	
	verbs_completed_label.text = "Completed: " + str(completed_count) + "/" + str(total_verbs)
	
	# Update verb ending
	verb_ending_label.text = "Ending: -" + current_verb["ending"]
	
	# Update total errors
	total_errors_label.text = "Total Errors: " + str(total_errors)
