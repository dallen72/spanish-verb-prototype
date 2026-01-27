class_name VerbData

# Static verb data - no instance needed, just reference VerbData.VERB_LIST
const VERB_LIST = [
	{
		"name": "Tener",
		"conjugations": {
			"yo": "tengo",
			"tu": "tienes", 
			"el": "tiene",
			"nosotros": "tenemos",
			"vosotros": "tenéis",
			"ellos": "tienen"
		},
		"english_phrases": {
			"yo": "I have",
			"tu": "You have",
			"el": "He/She has",
			"nosotros": "We have",
			"vosotros": "You all have",
			"ellos": "They have"
		},
		"sentence_templates": {
			"yo": "___ tengo hambre",
			"tu": "¿___ tienes tiempo?",
			"el": "___ tiene un coche",
			"nosotros": "___ tenemos clase",
			"vosotros": "¿___ tenéis dinero?",
			"ellos": "___ tienen muchos amigos"
		},
		"ending": "er"
	},
	{
		"name": "Hablar",
		"conjugations": {
			"yo": "hablo",
			"tu": "hablas",
			"el": "habla", 
			"nosotros": "hablamos",
			"vosotros": "hablais",
			"ellos": "hablan"
		},
		"english_phrases": {
			"yo": "I speak",
			"tu": "You speak",
			"el": "He/She speaks",
			"nosotros": "We speak",
			"vosotros": "You all speak",
			"ellos": "They speak"
		},
		"sentence_templates": {
			"yo": "___ hablo español",
			"tu": "¿___ hablas inglés?",
			"el": "___ habla francés",
			"nosotros": "___ hablamos mucho",
			"vosotros": "¿___ habláis italiano?",
			"ellos": "___ hablan chino"
		},
		"ending": "ar"
	},
	{
		"name": "Vivir",
		"conjugations": {
			"yo": "vivo",
			"tu": "vives",
			"el": "vive",
			"nosotros": "vivimos", 
			"vosotros": "vivis",
			"ellos": "viven"
		},
		"english_phrases": {
			"yo": "I live",
			"tu": "You live",
			"el": "He/She lives",
			"nosotros": "We live",
			"vosotros": "You all live",
			"ellos": "They live"
		},
		"sentence_templates": {
			"yo": "___ vivo en Madrid",
			"tu": "¿___ vives aquí?",
			"el": "___ vive en Barcelona",
			"nosotros": "___ vivimos juntos",
			"vosotros": "¿___ vivís cerca?",
			"ellos": "___ viven en París"
		},
		"ending": "ir"
	}
]

# Static utility functions for working with verb data
static func get_random_verb() -> Dictionary:
	return VERB_LIST[randi() % VERB_LIST.size()]

static func get_available_verbs(completed_verbs: Array) -> Array:
	var available = []
	for verb in VERB_LIST:
		if not verb["name"] in completed_verbs:
			available.append(verb)
	return available

static func get_random_available_verb(completed_verbs: Array) -> Dictionary:
	var available = get_available_verbs(completed_verbs)
	if available.size() > 0:
		return available[randi() % available.size()]
	else:
		# All verbs completed, return random verb
		return get_random_verb()

static func get_verb_by_name(name: String) -> Dictionary:
	for verb in VERB_LIST:
		if verb["name"] == name:
			return verb
	return {}

static func get_total_verb_count() -> int:
	return VERB_LIST.size()
