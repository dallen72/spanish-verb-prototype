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
var current_state: ResponsiveValue
var pronoun_name: String = ""
@onready var game_progress: Node = Global.get_node("GameProgressMaster")


func _ready():
	# Wait a frame to ensure theme and globals are ready
	await get_tree().process_frame
	current_state = ResponsiveValue.new(ButtonState.UNMATCHED)
	_init_text()
	current_state.changed.connect(update_ui)


func set_correct_state_and_matched_if(selected_button: PronounButton):
	if current_state.value == ButtonState.SELECTED:
		current_state.value = ButtonState.COMPLETED
	elif selected_button == self:
		current_state.value = ButtonState.SELECTED
			
	
func update_ui(new_state: ButtonState):
	mouse_filter = Control.MOUSE_FILTER_IGNORE	
	match current_state.value:
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
	return current_state.value == ButtonState.UNMATCHED


func is_completed() -> bool:
	return current_state.value == ButtonState.COMPLETED


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
