class_name CaughtState
extends BaseState


func _init() -> void:
	state_id = Global.StateID.CAUGHT


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	self.character = character
	character.is_caught = true


func update(_delta: float) -> void:
	print("deading")


func exit() -> void:
	pass
