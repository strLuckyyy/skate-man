class_name CoyoteTime
extends RefCounted

const COYOTE_TIMEOUT: float = 0.2
var _coyote_elapsed:  float = 0.0
var _ends:            bool  = false

var _controller: BaseController


func coyote_time_ends() -> bool: return _ends

func begin(character: BaseCharacter):
	_controller         = character.controller
	_coyote_elapsed    = 0.0
	_controller.can_jump = true


func update(delta: float) -> void:
	if _ends: return
	_coyote_elapsed += delta
	
	if _coyote_elapsed >= COYOTE_TIMEOUT:
		_controller.can_jump = false
		_ends                = true
