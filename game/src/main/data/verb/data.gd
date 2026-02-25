extends RefCounted
class_name VerbData

# Raw verb definitions (name, conjugations, english_phrases, sentence_templates, ending).
# Parsed into Verb instances via VerbDataAccess.
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
