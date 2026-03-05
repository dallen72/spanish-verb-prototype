extends StateMachine

const ON_TUTORIAL_CONTINUED = &"on_tutorial_continued"
const ON_TUTORIAL_STARTED = &"on_tutorial_started"

@onready var signals = Global.get_node("Signals")


func _ready():
	super()
	signals.tutorial_continued.connect(_on_tutorial_continued)

###########		State Machine Inputs	###########

func _on_tutorial_continued():
	if current_state and current_state.has_method(ON_TUTORIAL_CONTINUED):
		current_state.call(ON_TUTORIAL_CONTINUED)
