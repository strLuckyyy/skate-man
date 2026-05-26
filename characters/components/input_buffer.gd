class_name InputBuffer
extends Node


signal direction_input(direction: Global.Direction, pressed: bool)
signal direction_held(direction: Global.Direction)
signal direction_released(direction: Global.Direction)

## Time (in seconds) before the buffer is automatically cleared
const BUFFER_TIMEOUT: float = 1.5

## Maximum size of the input buffer.
## If the limit is exceeded, the oldest input is removed to make room for the new one
const BUFFER_SIZE: int = 8

var _buffer_time:     Timer
var _input_buffer:    Array[Global.Direction] = [ ]
var _held_directions: Dictionary              = { }

var input_deadzone := 0.1


func _ready() -> void:
	_buffer_time           = $Timer
	_buffer_time.wait_time = BUFFER_TIMEOUT


func _process(_delta: float) -> void:
	# Update held directions state
	_held_directions[Global.Direction.UP]    = Input.is_action_pressed("up")
	_held_directions[Global.Direction.DOWN]  = Input.is_action_pressed("down")
	_held_directions[Global.Direction.LEFT]  = Input.is_action_pressed("left")
	_held_directions[Global.Direction.RIGHT] = Input.is_action_pressed("right")

	# Emit held signals for currently pressed directions
	for dir in _held_directions:
		if _held_directions[dir]:
			direction_held.emit(dir)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("up"):
		if event.is_pressed() and not event.is_echo():
			direction_input.emit(Global.Direction.UP, true)
			_push_input(Global.Direction.UP)
		elif not event.is_pressed():
			direction_released.emit(Global.Direction.UP)

	elif event.is_action("down"):
		if event.is_pressed() and not event.is_echo():
			direction_input.emit(Global.Direction.DOWN, true)
			_push_input(Global.Direction.DOWN)
		elif not event.is_pressed():
			direction_released.emit(Global.Direction.DOWN)

	elif event.is_action("right"):
		if event.is_pressed() and not event.is_echo():
			direction_input.emit(Global.Direction.RIGHT, true)
			_push_input(Global.Direction.RIGHT)
		elif not event.is_pressed():
			direction_released.emit(Global.Direction.RIGHT)

	elif event.is_action("left"):
		if event.is_pressed() and not event.is_echo():
			direction_input.emit(Global.Direction.LEFT, true)
			_push_input(Global.Direction.LEFT)
		elif not event.is_pressed():
			direction_released.emit(Global.Direction.LEFT)


func _push_input(dir: Global.Direction) -> void:
	_input_buffer.append(dir)

	if _input_buffer.size() > BUFFER_SIZE:
		_input_buffer.pop_front()

	_buffer_time.start()


func _on_timer_timeout() -> void:
	_input_buffer.clear()


## Returns a copy of the current input buffer (not a reference)
func get_input_buffer() -> Array[Global.Direction]:
	return _input_buffer.duplicate()


## Returns a copy of the input buffer and clears it
func consume_buffer() -> Array[Global.Direction]:
	print("CONSUMIU BUFFER:", _input_buffer)
	var buffer_copy = get_input_buffer()
	_input_buffer.clear()
	return buffer_copy
