extends RefCounted
class_name ResponsiveValue

var _value: Variant

var value:
	get:
		return _value
	set(value):
		if value == _value:
			return
		_value = value
		changed.emit(value)

signal changed(new_value)

func _init(initial):
	_value = initial
