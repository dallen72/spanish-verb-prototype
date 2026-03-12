extends Node2D

const UI_TRANSITION_SLIDE_DURATION = 0.35

var initial_exercise: Exercise = ExerciseDataAccess.fetch_exercise_list()[0]

var is_tutorial: bool = true
