class_name OnGridingState
extends BaseState


const MIN_GRIND_SPEED:  float = 80.0
const GRIND_JUMP_BOOST: float = 1.1

var _grindable:        ObjectGrindable = null
var _grind_speed:      float = 0.0
var _grind_direction:  float = 1.0


func _init() -> void:
	state_id = Global.StateID.ON_GRIDING

# ---------------------------------------------------------------------------
# FSM interface
# ---------------------------------------------------------------------------

@warning_ignore("shadowed_variable_base_class")
func enter(character: BaseCharacter, payload = null) -> void:
	self.character = character

	_grindable = payload as ObjectGrindable
	if _grindable == null:
		push_warning("OnGridingState: entered without a valid ObjectGrindable payload.")
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
		return
	
	_grind_speed     = _grindable.grind_speed
	_grind_direction = 1.0
	
	character.can_move = false
	character.velocity = Vector2.ZERO
	
	_grindable.snap_to_nearest(character.global_position)


func update(delta: float) -> void:
	if _grindable == null:
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
		return
	
	_grindable.advance(_grind_speed * _grind_direction * delta)
	
	if Input.is_action_just_pressed("jump"):
		_exit_jump()
		return
	
	if _grindable.is_at_end():
		_exit_fail()
		return
	
	if _grind_direction < 0.0 and _grindable.is_at_start():
		_exit_fail()
		return


func exit() -> void:
	character.can_move = true
	character.stop_grind()
	
	_grindable.reset_anchor()
	_grindable = null

# ---------------------------------------------------------------------------
# Exit helpers
# ---------------------------------------------------------------------------

func _exit_jump() -> void:
	character.velocity.x = _grind_speed * _grind_direction
	
	character.velocity.y = character.controller.apply_jump(
		character.equipment.current_equipment
	) * GRIND_JUMP_BOOST
	
	character._is_jumping = true
	
	EventBus.grind_ended.emit()
	emit_signal("transition_requested", Global.StateID.ON_AIR, null)


func _exit_fail() -> void:
	character.velocity = Vector2.ZERO
	
	EventBus.grind_failed.emit()
	emit_signal("transition_requested", Global.StateID.TRICK_FAIL, null)
