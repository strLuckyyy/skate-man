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
		emit_signal("transition_requested", Global.StateID.ON_FALLING, null)
	
	if character.is_on_floor():
		character.reset_jump()
		
		var is_doing_trick  = character.trick_system.is_busy
		var is_bad_rotation = abs(character.rotation_degrees) > 25.0 
		
		if is_doing_trick or is_bad_rotation:
			emit_signal("transition_requested", Global.StateID.TRICK_FAIL, null)
		else:
			emit_signal("transition_requested", Global.StateID.ON_FLOOR,   null)


func exit() -> void:
	pass
