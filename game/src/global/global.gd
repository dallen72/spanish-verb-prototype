extends Node2D

const UI_TRANSITION_SLIDE_DURATION = 0.35

var initial_exercise = ExerciseDataAccess.fetch_exercise_list()[0]

## TODO: autoload everything in the directory  automatically, so you can just drop in an exercise
const PRONOUN_MATCHING_SCENE_PATH = "res://src/main/exercises/pronounmatching/PronounMatching.tscn"
const SENTENCE_COMPLETION_SCENE_PATH = "res://src/main/exercises/sentencecompletion/SentenceCompletion.tscn"

var is_tutorial: bool = true
