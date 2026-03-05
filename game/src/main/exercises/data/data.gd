extends RefCounted
class_name ExerciseData

# Raw exercise definitions (exercise_name, icon_path). Parsed into Exercise instances via ExerciseDataAccess.
const EXERCISE_LIST = [
	{"name": "english_pronoun_matching",
		"icon_path": "res://assets/icon.svg",
		"label_text_for_given": "English Pronouns",
	},
	{"name": "spanish_pronoun_matching",
		"icon_path": "res://assets/icon.svg",
		"label_text_for_given": "Spanish Pronouns",
	},
	{"name": "sentence_completion",
		"icon_path": "res://assets/icon.svg",
		"label_text_for_given": "Conjugation",
	},
]
