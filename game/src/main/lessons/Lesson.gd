
class_name Lesson


static func get_lesson_by_name(name: String):
	var lesson_data
	if name == "Tener":
		lesson_data = [
			{
				"main_text": "",
				"button_text": "First Verb: Tener"
			},
			{
				"main_text": "Tener means 'To have'. 'I have' is 'yo tengo', so 'tengo' is the first-person conjugation for Tener.",
				"button_text": "Continue...",
			}
		]
	elif name == "English Pronoun Matching":
		lesson_data = [
			{
				"main_text": "",
				"button_text": "First Exercise: Matching English Pronouns to Conjugations"
			},
			{
				"main_text": "Match the pronouns on the left with the Conjugations on the right",
				"button_text": "Continuemos",
			}
		]
	elif name == "Game Progress":
		lesson_data = [
			{
				"main_text": "",
				"button_text": "Game Progress: Exploring Your Learning Growth"
			},
			{
				"main_text": "The exercises you have unlocked are on the left, the verbs you have unlocked are on the right",
				"button_text": "Continuemos",
			}
		]	
	return lesson_data


static func unlock_lesson_if_criteria_met(current_exercise: Exercise, previous_score: int, lessons_unlocked_list: Array[String]):
	if (current_exercise.name == Global.ENGLISH_PRONOUN_MATCHING_EXERCISE_NAME):
		if (not lessons_unlocked_list.has(Global.GAME_PROGRESS_LESSON_NAME)):
			lessons_unlocked_list.append(Global.GAME_PROGRESS_LESSON_NAME)
	
