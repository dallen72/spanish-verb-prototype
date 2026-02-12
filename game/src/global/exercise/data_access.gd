extends RefCounted
class_name ExerciseDataAccess


# Parses ExerciseData into Exercise instances.
static func _parse_exercise(raw: Dictionary) -> Exercise:
	var e := Exercise.new()
	e.name = raw.get("name", "")
	e.icon_path = raw.get("icon_path", "")
	return e

static func fetch_exercise_list() -> Array[Exercise]:
	var result: Array[Exercise] = []
	for raw in ExerciseData.EXERCISE_LIST:
		result.append(_parse_exercise(raw))
	return result
