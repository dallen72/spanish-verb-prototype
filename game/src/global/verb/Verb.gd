extends RefCounted
class_name Verb

# Instance-only: data comes from VerbData and is parsed via VerbDataAccess.

var name: String = ""
var conjugations: Dictionary = {}
var english_phrases: Dictionary = {}
var sentence_templates: Dictionary = {}
var ending: String = ""

func to_dict() -> Dictionary:
	return {
		"name": name,
		"conjugations": conjugations,
		"english_phrases": english_phrases,
		"sentence_templates": sentence_templates,
		"ending": ending
	}
