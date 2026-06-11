class_name TrickFailState
extends BaseState

const RECOVER_TIMEOUT:    float = 1.0
var current_recover_time: float = 0.0
var has_crashed:          bool  = false

var _slide_vel_value: float = 80.
var _slide_distance:  float = 10.

var pre_velo    := Vector2.ZERO
var coyote_time := CoyoteTime.new()


func _init() -> void:
	state_id = Global.StateID.TRICK_FAIL


@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, payload = null) -> void:
	super.enter(p_character, payload)
	controller.is_trick_fail = true
	controller.set_permissions(false, false)
	has_crashed              = false
	current_recover_time     = 0.0
	
	coyote_time.begin(character)
	
	if payload != null:
		character.velocity = payload
	
	if character.is_on_floor():
		_trigger_crash()
	
	character.boost_component.reset_boost()


func update(delta: float) -> void:
	if not has_crashed:
		pre_velo = character.velocity
		coyote_time.update(delta)
		
		if controller.is_jumped():
			emit_signal("transition_requested", Global.StateID.ON_AIR, null)
		
		if character.is_on_floor():
			_trigger_crash()
	else:
		current_recover_time += delta
		
		controller.can_jump = false
		controller.can_move = false
		
		if character.velocity.x > pre_velo.x + _slide_distance:
			character.velocity.x = 0.0
		
		if current_recover_time >= RECOVER_TIMEOUT:
			emit_signal("transition_requested", Global.StateID.ON_FLOOR, null)
	character.move_and_slide()


func _trigger_crash() -> void:
	has_crashed = true
	character.velocity.x = _slide_vel_value
	#character.velocity.y = -80.0


func exit() -> void:
	controller.is_trick_fail = false
	controller.can_jump      = true
	controller.can_move      = true
	current_recover_time    = 0.0
