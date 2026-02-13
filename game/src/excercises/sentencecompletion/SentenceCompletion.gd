extends VBoxContainer

# Game state variables for sentence completion
var current_conjugation_for_sentences: String = ""
var current_pronoun_for_sentences: String = ""

# UI references
@onready var conjugation_display_button: Button = $MarginContainer/GameArea/ConjugationSection/ConjugationMarginContainer/ConjugationDisplay
@onready var sentence_container: GridContainer = $MarginContainer/GameArea/SentenceSection/SentenceMarginContainer/SentenceGrid

func _ready():
	# Connect sentence button signals
	for button in sentence_container.get_children():
		if button is Button:
			button.pressed.connect(_on_sentence_button_pressed.bind(button))

func setup_problem():
	var current_verb: Verb = Global.get_node("GameProgressMaster").get_current_verb()
	if current_verb == null:
		return
	
	# Pick a random conjugation to display
	var pronouns = current_verb.conjugations.keys()
	var random_pronoun = pronouns[randi() % pronouns.size()]
	current_pronoun_for_sentences = random_pronoun
	current_conjugation_for_sentences = current_verb.conjugations[random_pronoun]
	
	# Set the conjugation display button
	conjugation_display_button.text = current_conjugation_for_sentences
	
	# Reset sentence buttons
	for button in sentence_container.get_children():
		if button is Button:
			button.disabled = false
			button.modulate = Color.WHITE
			var pronoun = button.name.replace("sentence_", "")
			button.text = current_verb.sentence_templates[pronoun]

func _on_sentence_button_pressed(button: Button):
	var pronoun = button.name.replace("sentence_", "")
	
	# Check if this is the correct match
	if pronoun == current_pronoun_for_sentences:
		# Correct match!
		button.modulate = Color.LIGHT_BLUE
		button.disabled = true
		var current_verb: Verb = Global.get_node("GameProgressMaster").get_current_verb()
		if current_verb != null:
			button.text = current_verb.sentence_templates[pronoun].replace("___", current_pronoun_for_sentences)
		
		# Mark as completed and move to next problem
		Global.get_node("Signals").emit_signal("problem_completed")
	else:
		# Incorrect match
		Global.get_node("Signals").emit_signal("wrong_selection")
		
		#TODO: abstract so that can be re-used, do in the pronounmatching
		# Visual feedback for wrong answer
		button.modulate = Color.RED
		await get_tree().create_timer(0.5).timeout
		button.modulate = Color.WHITE
