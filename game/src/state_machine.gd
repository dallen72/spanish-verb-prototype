extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	assert(initial_state, "Initial state not set")

	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_state_transition)

	current_state = initial_state
	current_state.enter()

func _process(delta: float):
	if current_state:
		current_state.update(delta)

func _physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

func _on_state_transition(state, new_state_name):
	if state != current_state:
		assert(false, "State transition rejected: %s != %s" % [state.name, current_state.name])
		return

	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		assert(false, "State transition rejected: %s not found" % new_state_name.to_lower())
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
