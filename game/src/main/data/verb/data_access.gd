extends RefCounted
class_name VerbDataAccess


# Parses VerbData into Verb instances and provides accessors.
static func parse_verb(raw: Dictionary) -> Verb:
	var v := Verb.new()
	v.name = raw.get("name", "")
	v.conjugations = raw.get("conjugations", {})
	v.english_phrases = raw.get("english_phrases", {})
	v.sentence_templates = raw.get("sentence_templates", {})
	v.ending = raw.get("ending", "")
	return v


static func fetch_all_verbs() -> Array[Verb]:
	var result: Array[Verb] = []
	for raw in VerbData.VERB_LIST:
		result.append(parse_verb(raw))
	return result


static func get_total_verb_count() -> int:
	return VerbData.VERB_LIST.size()
