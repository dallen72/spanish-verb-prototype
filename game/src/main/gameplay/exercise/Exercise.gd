extends RefCounted
class_name Exercise

# Instance-only: data comes from ExerciseData and is parsed via ExerciseDataAccess.

var name: String = ""
var icon_path: String = ""
var completed_verbs: Array[String] = []
