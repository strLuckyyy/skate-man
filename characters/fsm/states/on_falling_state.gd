class_name OnFallingState
extends BaseState


func _init() -> void:
	state_id = Global.StateID.ON_FALLING


@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, payload = null) -> void:
	super.enter(p_character, payload)
	controller.set_permissions(false, false)


func update(_delta: float) -> void:
	if character.is_on_floor():
		emit_signal("transition_requested", Global.StateID.ON_FLOOR, null)
	character.apply_momentum(Vector2.UP)


func exit() -> void:
	pass
