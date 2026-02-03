class_name Exercise

# Icon resource path per exercise (aligned with VerbData.VERB_LIST verb names).
# Placeholder: all use the same icon; replace paths for per-exercise icons later.
const EXERCISE_LIST = [
	{"exercise_name": "english_pronoun_matching", "icon_path": "res://assets/icon.svg"},
	{"exercise_name": "spanish_pronoun_matching", "icon_path": "res://assets/icon.svg"},
	{"exercise_name": "sentence_completion", "icon_path": "res://assets/icon.svg"},
]

# Excercises have a name and a verb list of completed verbs for that excercise
var name: String
var completed_verbs: Array[String]
