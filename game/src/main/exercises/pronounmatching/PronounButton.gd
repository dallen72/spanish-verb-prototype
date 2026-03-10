extends Button
class_name PronounButton
#TODO: convert all input events to use control._gui_input()
## Button that is matched with conjugations

# Finite state machine for pronoun buttons
enum ButtonState {
	UNMATCHED,  # Default state - not selected, not matched
	SELECTED,   # Currently selected (waiting for conjugation match)
	COMPLETED   # Successfully matched with a conjugation
}

## TODO: reactivevalue
var current_state: ButtonState = ButtonState.UNMATCHED
var pronoun_name: String = ""
@onready var game_progress: Node = Global.get_node("GameProgressMaster")

## TODO: put this in another file for conjugation_buttons
#button_state.changed.connect(on_conjugation_button_changed):
	#for pronoun_button in pronoun_buttons:
		#if pronoun_button.pronoun == conjugation_button.pronoun:
			#conjugation_button.completed_state = STATE.COMPLETED


func _ready():
	# Wait a frame to ensure theme and globals are ready
	await get_tree().process_frame
	set_state(ButtonState.UNMATCHED)
	_init_text() 


func set_correct_state_and_matched_if(selected_button: PronounButton):
	if selected_button == self:
		set_state(PronounButton.ButtonState.SELECTED)	
	elif is_selected():
		set_state(PronounButton.ButtonState.UNMATCHED)
	

func set_state(new_state: ButtonState):
	"""Updates the button state and appearance."""
	current_state = new_state

	## TODO: three variations: default, selected, completed for button theme		
	mouse_filter = Control.MOUSE_FILTER_IGNORE	
	match current_state:
		ButtonState.UNMATCHED:
			# Unmatched: use shared brown background and text color, ignore clicks
			modulate = Color.WHITE
			disabled = true		
		
		ButtonState.SELECTED:
			# Selected: green color, ignore mouse clicks
			modulate = Color.GREEN
			disabled = false
		
		ButtonState.COMPLETED:
			disabled = true
			theme_type_variation = "CompletedButton"


func is_unmatched() -> bool:
	return current_state == ButtonState.UNMATCHED

func is_selected() -> bool:
	return current_state == ButtonState.SELECTED

func is_completed() -> bool:
	return current_state == ButtonState.COMPLETED


func _init_text():
	pronoun_name = name
	if game_progress.current_exercise.name == "english_pronoun_matching":
		# Use English phrases
		var phrase = game_progress.current_verb.english_phrases.get(pronoun_name, "")
		text = (phrase + "..." if phrase != "" else pronoun_name + "...")
	elif game_progress.current_exercise.name == "spanish_pronoun_matching":
		text = pronoun_name + "..."


func update_text_for_match(conjugation_text: String, exercise: String, english_phrase: String = ""):
	"""Updates the button text to show the completed match."""
	if exercise == "english_pronoun_matching":
		text = english_phrase + ": " + conjugation_text
	else:
		text = pronoun_name + " " + conjugation_text
