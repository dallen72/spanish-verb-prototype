class_name ExerciseData

# Icon resource path per exercise (aligned with VerbData.VERB_LIST verb names).
# Placeholder: all use the same icon; replace paths for per-exercise icons later.
const EXERCISE_LIST = [
	{"name": "Tener", "icon_path": "res://assets/icon.svg"},
	{"name": "Hablar", "icon_path": "res://assets/icon.svg"},
	{"name": "Vivir", "icon_path": "res://assets/icon.svg"}
]

static func get_icon_path(verb_name: String) -> String:
	for entry in EXERCISE_LIST:
		if entry["name"] == verb_name:
			return entry["icon_path"]
	return "res://assets/icon.svg"
