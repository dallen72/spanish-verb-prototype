extends ResponsiveValue
## A ResponsiveValue that is derived from 1+ other ResponsiveValues.

class_name ResponsiveFnValue

var _get_value: Callable
var _args: Array
var _dependencies: Array[ResponsiveValue]

## For example, ResponsiveFnValue.new([value1Obj, value2Obj], func(value1, value2):
##	return value1 + value2)
func _init(dependencies: Array[ResponsiveValue], get_value: Callable):
	_get_value = get_value
	_dependencies = dependencies
	
	_args = []
	for i in range(_dependencies.size()):
		var dep = _dependencies[i]
		_args.append(dep.value)
		dep.changed.connect(func(v):
			_args[i] = v
			_update())
	super._init(get_value.callv(_args))

func _update():
	value = _get_value.callv(_args)

# TODO Convert to unit testing
static func test():
	var a = ResponsiveValue.new(0)
	var b = ResponsiveValue.new(2)
	var _sum = ResponsiveFnValue.new([a, b], func(a1, b1):
		print("  calc sum ", a1, " + ", b1)
		return a1 + b1)
	_sum.changed.connect(func(sum):
		print("  new sum: ", sum))
	print("sum ", _sum)
	print("change a")
	a.value = 5
	print("change b")
	b.value = 20
	print("done test")
