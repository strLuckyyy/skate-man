class_name TrickFailState
extends BaseState

func _init() -> void:
	state_id = Global.StateID.TRICK_FAIL


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	print("trick fail")
	character.velocity = Vector2.ZERO


func update(_delta: float) -> void:
	print("rising")


func exit() -> void:
	pass
