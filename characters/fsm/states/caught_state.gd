class_name CaughtState
extends BaseState


func _init() -> void:
	state_id = Global.StateID.CAUGHT


@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, payload = null) -> void:
	super.enter(p_character, payload)
	character.is_caught = true
	controller.set_permissions(false, false)


func update(_delta: float) -> void:
	print("deading")


func exit() -> void:
	pass
