class_name OnFallingState
extends BaseState


func _init() -> void:
	state_id = Global.StateID.ON_FALLING


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	self.character = character
	character.can_jump = false


func update(_delta: float) -> void:	
	if character.is_grinding():
		emit_signal("transition_requested", Global.StateID.ON_GRIDING)
	
	if character.is_on_floor():
		emit_signal("transition_requested", Global.StateID.ON_FLOOR)


func exit() -> void:
	pass
