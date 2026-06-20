class_name Countdown
extends RefCounted

var _duration: float = 3.0
var _elapsed: float = 0.0
var _ended: bool = false

func countdown_ended() -> bool:
	return _ended

func begin(duration: float = 3.0) -> void:
	_duration = duration
	_elapsed = 0.0
	_ended = false

func update(delta: float) -> void:
	if _ended:
		return

	_elapsed += delta

	if _elapsed >= _duration:
		_ended = true

func get_remaining_time() -> float:
	return maxf(0.0, _duration - _elapsed)

func get_remaining_seconds() -> int:
	return ceili(get_remaining_time())
