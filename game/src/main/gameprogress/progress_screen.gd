extends Control

@onready var UIUtils = Global.get_node("UIUtils")

@onready var main_text_label: Label = %MainText
@onready var main_tutorial_button: Button = %MainTutorialButton

var button_flash_tween: Tween

var lesson_iterator = 0
var current_lesson
var showing_lesson: bool = false

func show_progress_screen():
	%UIManager.show_progress_screen()


func start_lesson_with_name(lesson_name: String):
	var lesson = Lesson.get_lesson_by_name(lesson_name)
	current_lesson = lesson
	continue_lesson()

func continue_lesson():
	if lesson_iterator > 1:
		lesson_iterator = 0
		
	show_lesson_page(current_lesson)
	showing_lesson = true
	lesson_iterator += 1	
	if lesson_iterator > 1:
		showing_lesson = false
		

func show_lesson_page(lesson):
	if button_flash_tween:
		button_flash_tween.kill()
	main_text_label.text = lesson[lesson_iterator].main_text
	main_tutorial_button.text = lesson[lesson_iterator].button_text
	button_flash_tween = UIUtils.flash_text_node(main_tutorial_button)
