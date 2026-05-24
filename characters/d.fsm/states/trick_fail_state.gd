class_name TrickFailState
extends BaseState

const RECOUVER_TIMEOUT:    float = 1.
var current_recouver_time: float = 0.

var coyote_time := CoyoteTime.new()


func _init() -> void:
	state_id = Global.StateID.TRICK_FAIL


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	self.character        = character as BaseCharacter
	character.velocity    = -character.velocity
	character.can_move    = false
	current_recouver_time = 0.0
	coyote_time.begin(character)


func update(delta: float) -> void:
	coyote_time.update(delta)
	
	current_recouver_time  += delta
	character.is_trick_fail = true
	
	if character.jumped():
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
	
	if current_recouver_time >= RECOUVER_TIMEOUT:
		character.can_jump = false
		emit_signal("transition_requested", Global.StateID.ON_FLOOR, null)


func exit() -> void:
	character.can_jump    = true
	character.can_move    = true
	current_recouver_time = 0.0
