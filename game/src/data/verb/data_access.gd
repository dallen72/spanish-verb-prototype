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


static func fetch_all_verbs() -> Variant:
	var result_array: Array[Verb] = []
	for raw in VerbData.VERB_LIST:
		result_array.append(parse_verb(raw))
	if result_array.size() < 1:
		return null
	else:
		return result_array
	
	
static func fetch_verb_where_name_is(_name: String) -> Variant:
	for raw in VerbData.VERB_LIST:
		if raw.name == _name:	
			return parse_verb(raw)
	return null
