extends Control

# UI references
@onready var verb_ending_label: Label = $VBoxContainer/VerbEndingLabel
@onready var current_verb_label: Label = $VBoxContainer/CurrentVerbLabel
@onready var total_errors_label: Label = $VBoxContainer/TotalErrorsLabel
@onready var verbs_completed_label: Label = $VBoxContainer/VerbsCompletedLabel

func _ready():
	var game_progress = Global.get_node("GameProgressMaster")
	game_progress.total_errors.changed.connect(_update_error_label)
	

func _update_error_label(value):
	total_errors_label.text = "Total Errors: " + str(value)


# Public methods for updating progress display
func update_progress():
	var game_progress = Global.get_node("GameProgressMaster")
	var current_verb: Verb = game_progress.get_current_verb()
	#var completed_verbs = game_progress.get_verbs_completed_for_excercise()
	var total_errors: ResponsiveValue = game_progress.total_errors
	
	# Update verb ending (first)
	verb_ending_label.text = "Ending: -" + (current_verb.ending if current_verb else "")
	
	# Update current verb
	current_verb_label.text = "current verb: " + (current_verb.name if current_verb else "")
	
		
	# Update verbs completed
	#var total_verbs = VerbDataAccess.get_total_verb_count()
	#var completed_count = completed_verbs.size()
	
	#verbs_completed_label.text = "Completed: " + str(completed_count) + "/" + str(total_verbs)
