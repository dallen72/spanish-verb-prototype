extends RefCounted
class_name ExerciseData

# Raw exercise definitions (exercise_name, icon_path). Parsed into Exercise instances via ExerciseDataAccess.
const EXERCISE_LIST = [
	{"name": "english_pronoun_matching",
		"icon_path": "res://assets/icon.svg",
		"label_text_for_given": "English Pronouns",
		"path": "res://src/main/exercises/pronounmatching/PronounMatching.tscn",
	},
	{"name": "spanish_pronoun_matching",
		"icon_path": "res://assets/icon.svg",
		"label_text_for_given": "Spanish Pronouns",
		"path": "res://src/main/exercises/pronounmatching/PronounMatching.tscn",
	},
	{"name": "sentence_completion",
		"icon_path": "res://assets/icon.svg",
		"label_text_for_given": "Conjugation",
		"path": "res://src/main/exercises/sentencecompletion/SentenceCompletion.tscn",
	},
]
