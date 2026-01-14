extends Node

# Game state variables - accessible globally
var current_verb: Dictionary = {}
var completed_verbs: Array = []
var total_errors: int = 0
var previous_score: int = 0

func get_current_verb() -> Dictionary:
	return current_verb

func set_current_verb(verb: Dictionary):
	current_verb = verb

func add_completed_verb(verb_name: String):
	if not completed_verbs.has(verb_name):
		completed_verbs.append(verb_name)

func get_completed_verbs() -> Array:
	return completed_verbs

func clear_completed_verbs():
	completed_verbs.clear()

func increment_total_errors():
	total_errors += 1

func get_total_errors() -> int:
	return total_errors

func set_previous_score(score: int):
	previous_score = score

func get_previous_score() -> int:
	return previous_score

func reset_previous_score():
	previous_score = 0
