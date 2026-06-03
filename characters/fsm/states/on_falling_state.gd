class_name OnFallingState
extends BaseState


func _init() -> void:
	state_id = Global.StateID.ON_FALLING


@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, payload = null) -> void:
	super.enter(p_character, payload)
	character.can_jump = false


func update(delta: float) -> void:
	controller.apply_gravity(delta, character)
	
	if character.is_on_floor():
		emit_signal("transition_requested", Global.StateID.ON_FLOOR, null)


func exit() -> void:
	pass
