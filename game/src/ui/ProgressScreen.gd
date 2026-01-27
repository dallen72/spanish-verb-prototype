extends Control

# Signals for communicating with parent scenes
signal progress_screen_closed

# Configuration
var display_duration: float = 3.0

# UI references will be created programmatically for the bar chart
var chart_container: Control = null

func _ready():
	# Get the chart container node (inside VBoxContainer)
	chart_container = $VBoxContainer/ChartContainer
	# Connect the draw signal
	chart_container.draw.connect(_on_chart_draw)

func _on_chart_draw():
	_draw_bar_chart()

func _draw_bar_chart():
	var game_progress = Global.get_node("GameProgressMaster")
	var completed_verbs = game_progress.get_completed_verbs()
	var total_verbs = VerbData.get_total_verb_count()
	var total_errors = game_progress.get_total_errors()

	# Get chart dimensions
	var chart_rect = chart_container.get_rect()
	var chart_width = chart_rect.size.x
	var chart_height = chart_rect.size.y

	# Bar chart settings
	var bar_width = 120.0
	var bar_spacing = 60.0
	var max_bar_height = chart_height - 80  # Leave room for labels
	var base_y = chart_height - 40  # Bottom margin for labels

	# Calculate starting x to center the bars
	var total_chart_width = (bar_width * 2) + bar_spacing
	var start_x = (chart_width - total_chart_width) / 2

	# Colors
	var completed_color = Color(0.2, 0.7, 0.3, 1.0)  # Green
	var remaining_color = Color(0.6, 0.6, 0.6, 0.5)  # Gray
	var error_color = Color(0.8, 0.3, 0.3, 1.0)  # Red
	var text_color = Color(1, 1, 1, 1)  # White

	# Draw "Verbs Completed" bar
	var verbs_bar_height = (float(completed_verbs.size()) / float(total_verbs)) * max_bar_height if total_verbs > 0 else 0
	var verbs_remaining_height = max_bar_height - verbs_bar_height

	# Background bar (remaining)
	var remaining_rect = Rect2(start_x, base_y - max_bar_height, bar_width, verbs_remaining_height)
	chart_container.draw_rect(remaining_rect, remaining_color)

	# Completed bar
	if verbs_bar_height > 0:
		var completed_rect = Rect2(start_x, base_y - verbs_bar_height, bar_width, verbs_bar_height)
		chart_container.draw_rect(completed_rect, completed_color)

	# Draw bar outline
	var full_bar_rect = Rect2(start_x, base_y - max_bar_height, bar_width, max_bar_height)
	chart_container.draw_rect(full_bar_rect, Color(1, 1, 1, 0.8), false, 2.0)

	# Draw label for verbs bar
	var verbs_label = "Verbs"
	var font = ThemeDB.get_fallback_font()
	var font_size = 20
	var label_width = font.get_string_size(verbs_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	chart_container.draw_string(font, Vector2(start_x + (bar_width - label_width) / 2, base_y + 25), verbs_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

	# Draw count on top of verbs bar
	var verbs_count = str(completed_verbs.size()) + "/" + str(total_verbs)
	var count_width = font.get_string_size(verbs_count, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	chart_container.draw_string(font, Vector2(start_x + (bar_width - count_width) / 2, base_y - max_bar_height - 10), verbs_count, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

	# Draw "Errors" bar
	var errors_bar_x = start_x + bar_width + bar_spacing
	var max_errors_display = 10  # Cap at 10 for display purposes
	var errors_normalized = min(total_errors, max_errors_display)
	var errors_bar_height = (float(errors_normalized) / float(max_errors_display)) * max_bar_height if max_errors_display > 0 else 0

	# Background bar for errors
	var errors_bg_rect = Rect2(errors_bar_x, base_y - max_bar_height, bar_width, max_bar_height)
	chart_container.draw_rect(errors_bg_rect, remaining_color)

	# Errors bar
	if errors_bar_height > 0:
		var errors_rect = Rect2(errors_bar_x, base_y - errors_bar_height, bar_width, errors_bar_height)
		chart_container.draw_rect(errors_rect, error_color)

	# Draw bar outline
	chart_container.draw_rect(errors_bg_rect, Color(1, 1, 1, 0.8), false, 2.0)

	# Draw label for errors bar
	var errors_label = "Errors"
	var errors_label_width = font.get_string_size(errors_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	chart_container.draw_string(font, Vector2(errors_bar_x + (bar_width - errors_label_width) / 2, base_y + 25), errors_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

	# Draw count on top of errors bar
	var errors_count = str(total_errors)
	var errors_count_width = font.get_string_size(errors_count, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	chart_container.draw_string(font, Vector2(errors_bar_x + (bar_width - errors_count_width) / 2, base_y - max_bar_height - 10), errors_count, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

func show_progress_screen():
	# Force redraw of the chart
	if chart_container:
		chart_container.queue_redraw()
	visible = true

func hide_progress_screen():
	visible = false
	progress_screen_closed.emit()

func show_progress_screen_with_timer(duration: float = 3.0):
	show_progress_screen()
	await get_tree().create_timer(duration).timeout
	hide_progress_screen()
