class_name TrickFailState
extends BaseState

const RECOUVER_TIMEOUT:    float = 0.8
var current_recouver_time: float = 0.

var coyote_time := CoyoteTime.new()


func _init() -> void:
	state_id = Global.StateID.TRICK_FAIL


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	character.velocity    = Vector2.ZERO
	current_recouver_time = 0.0
	coyote_time.begin(character)


func update(delta: float) -> void:
	coyote_time.update(delta)
	
	current_recouver_time  += delta
	character.is_trick_fail = true
	
	if current_recouver_time >= RECOUVER_TIMEOUT:
		emit_signal("transition_requested", Global.StateID.ON_FLOOR, null)


func exit() -> void:
	print("")
