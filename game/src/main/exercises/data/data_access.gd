extends RefCounted
class_name ExerciseDataAccess


# Parses ExerciseData into Exercise instances.
static func _parse_exercise(raw: Dictionary) -> Exercise:
	var e := Exercise.new()
	e.name = raw.get("name", "")
	e.icon_path = raw.get("icon_path", "")
	e.label_text_for_given = raw.get("label_text_for_given", "")
	e.path = raw.get("path")
	return e

static func fetch_exercise_list() -> Variant:
	var result_array: Array[Exercise] = []
	for raw in ExerciseData.EXERCISE_LIST:
		result_array.append(_parse_exercise(raw))
	
	if result_array.size() < 1:
		return null
	else:
		return result_array	
