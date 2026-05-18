class_name OnAirState
extends BaseState

const COYOTE_TIMEOUT: float = 0.1
const FALL_TIMEOUT: float = 1.5
var _coyote_elapsed: float = 0.0
var _fall_elapsed: float = 0.0


func _init() -> void:
	state_id = Global.StateID.ON_AIR


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	self.character = character
	_coyote_elapsed = 0.0
	_fall_elapsed = 0.0
	character.can_jump = true


func update(delta: float) -> void:
	_coyote_elapsed += delta
	_fall_elapsed += delta
	
	if _coyote_elapsed >= COYOTE_TIMEOUT:
		character.can_jump = false
	
	if _fall_elapsed >= FALL_TIMEOUT:
		emit_signal("transition_requested", Global.StateID.ON_FALLING)
	
	if character.is_grinding():
		emit_signal("transition_requested", Global.StateID.ON_GRIDING)
	
	if character.is_on_floor():
		character.reset_jump()
		emit_signal("transition_requested", Global.StateID.ON_FLOOR)


func exit() -> void:
	pass
