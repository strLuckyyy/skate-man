class_name InputBuffer extends Node

## Time (in seconds) before the buffer is automatically cleared
const BUFFER_TIMEOUT: float = 1.5

## Maximum size of the input buffer.
## If the limit is exceeded, the oldest input is removed to make room for the new one
const BUFFER_SIZE: int = 8

var _buffer_time: Timer
var _input_buffer: Array[Global.Direction] = []

var input_deadzone := 0.1

func _ready() -> void:
	_buffer_time = $Timer
	_buffer_time.wait_time = BUFFER_TIMEOUT


func _unhandled_input(event: InputEvent) -> void: 
	#This part need to accept keyboard, game-controller(playstation, xbox and generic) and touch-screen
	#but - dont receive if input is on menu, hud or whatever thing out maneuvers inputs
	
	if event.is_action("up") and event.is_pressed() and not event.is_echo():
		_push_input(Global.Direction.UP)

	elif event.is_action("down") and event.is_pressed() and not event.is_echo():
		_push_input(Global.Direction.DOWN)

	elif event.is_action("right") and event.is_pressed() and not event.is_echo():
		_push_input(Global.Direction.RIGHT)

	elif event.is_action("left") and event.is_pressed() and not event.is_echo():
		_push_input(Global.Direction.LEFT)


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
