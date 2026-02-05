extends RefCounted
class_name VerbDataAccess

# Parses VerbData into Verb instances and provides accessors.

static func _parse_verb(raw: Dictionary) -> Verb:
	var v := Verb.new()
	v.name = raw.get("name", "")
	v.conjugations = raw.get("conjugations", {})
	v.english_phrases = raw.get("english_phrases", {})
	v.sentence_templates = raw.get("sentence_templates", {})
	v.ending = raw.get("ending", "")
	return v

static func get_all_verbs() -> Array[Verb]:
	var result: Array[Verb] = []
	for raw in VerbData.VERB_LIST:
		result.append(_parse_verb(raw))
	return result

static func get_random_verb() -> Verb:
	var list = VerbData.VERB_LIST
	return _parse_verb(list[randi() % list.size()])

static func get_total_verb_count() -> int:
	return VerbData.VERB_LIST.size()

static func get_verb_by_name(verb_name: String) -> Verb:
	for raw in VerbData.VERB_LIST:
		if raw.get("name", "") == verb_name:
			return _parse_verb(raw)
	return null

static func get_available_verbs(completed_verb_names: Array) -> Array[Verb]:
	var result: Array[Verb] = []
	for raw in VerbData.VERB_LIST:
		var name_str: String = raw.get("name", "")
		if name_str not in completed_verb_names:
			result.append(_parse_verb(raw))
	return result

static func get_random_available_verb(completed_verb_names: Array) -> Verb:
	var available = get_available_verbs(completed_verb_names)
	if available.size() > 0:
		return available[randi() % available.size()]
	return get_random_verb()
