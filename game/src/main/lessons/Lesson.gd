
class_name Lesson


static func get_lesson_by_name(name: String):
	var lesson_data
	if name == "first":
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
	else:
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
	
	return lesson_data
