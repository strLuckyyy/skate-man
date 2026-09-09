class_name OnAirState
extends BaseState

const FALL_TIMEOUT:   float = 1.5
var _fall_elapsed:    float = 0.0

var coyote_time := CoyoteTime.new()


func _init() -> void:
	state_id = Global.StateID.ON_AIR


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, payload = null) -> void:
	super.enter(p_character, payload)
	_fall_elapsed   = 0.0
	coyote_time.begin(character)
	controller.set_permissions(false, true)


func update(delta: float) -> void:
	_fall_elapsed += delta
	coyote_time.update(delta)
	
	character.apply_momentum(Vector2.UP)
	
	if _fall_elapsed >= FALL_TIMEOUT:
		emit_signal("transition_requested", Global.StateID.ON_FALLING, null)
	
	if character.is_on_floor():
		controller.reset_jumped()
		
		var is_doing_trick = character.trick_system.get_is_doing_trick()
		
		if is_doing_trick:
			emit_signal("transition_requested", Global.StateID.TRICK_FAIL, null)
			print("Transitioning to TRICK_FAIL state from ON_AIR state due to trick execution.")
		else:
			emit_signal("transition_requested", Global.StateID.ON_FLOOR,   null)


func exit() -> void:
	pass
