class_name OnFloorState
extends BaseState


func _init() -> void:
	state_id = Global.StateID.ON_FLOOR


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, payload = null) -> void:
	super.enter(p_character, payload)
	controller.set_permissions(true, true)


func update(_delta: float) -> void:
	if not character.is_on_floor():
		emit_signal("transition_requested", Global.StateID.ON_AIR)
	character.apply_momentum(character.get_floor_normal())


func exit() -> void:
	pass
