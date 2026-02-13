extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

var state_transition_queue: Array[State] = []

#FIFO (First In, First Out) in GDScript is typically implemented using a Godot Array as a queue, where items are added to the back using push_back() and removed from the front using pop_front(). For a more efficient, dedicated FIFO structure, you can

func _ready():
	assert(initial_state, "Initial state not set")

	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_state_transition)

	current_state = initial_state
	current_state.enter()

func _process(delta: float):
	if not state_transition_queue.is_empty():
		if current_state:
			current_state.exit()

		current_state = state_transition_queue.pop_front()
		current_state.enter()
	elif (current_state and current_state != initial_state):
		current_state.update(delta)

func _physics_update(delta: float):
	if current_state and current_state != initial_state:
		current_state.physics_update(delta)

func _on_state_transition(state, new_state_name):
	if state != current_state:
		assert(false, "State transition rejected: %s != %s" % [state.name, current_state.name])
		return

	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		assert(false, "State transition rejected: %s not found" % new_state_name.to_lower())
		return

	state_transition_queue.push_back(new_state)
