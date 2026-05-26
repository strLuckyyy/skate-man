class_name OnAirState
extends BaseState

const FALL_TIMEOUT:   float = 1.5
var _fall_elapsed:    float = 0.0

var coyote_time := CoyoteTime.new()


func _init() -> void:
	state_id = Global.StateID.ON_AIR


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: BaseCharacter, payload = null) -> void:
	self.character  = character
	_fall_elapsed   = 0.0
	coyote_time.begin(character)


func update(delta: float) -> void:
	_fall_elapsed   += delta
	coyote_time.update(delta)
	
	if _fall_elapsed >= FALL_TIMEOUT:
		emit_signal("transition_requested", self, Global.StateID.ON_FALLING, null)
	
	if character.is_on_floor():
		character.reset_jump()
		emit_signal("transition_requested", self, Global.StateID.ON_FLOOR, null)


func exit() -> void:
	pass
