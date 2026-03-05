extends Node2D

const UI_TRANSITION_SLIDE_DURATION = 0.35

var initial_exercise = ExerciseDataAccess.fetch_exercise_list()[0]

var is_tutorial: bool = true

var exercise_scene_list = [
	{
		"name": "english_pronoun_matching",
		"path": "res://src/main/exercises/pronounmatching/PronounMatching.tscn",
	},
	{
		"name": "spanish_pronoun_matching",
		"path": "res://src/main/exercises/pronounmatching/PronounMatching.tscn",
	},
	{
		"name": "sentence_completion",
		"path": "res://src/main/exercises/sentencecompletion/SentenceCompletion.tscn",
	}
]	
