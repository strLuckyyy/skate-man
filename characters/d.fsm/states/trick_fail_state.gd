class_name TrickFailState
extends BaseState


const RECOUVER_TIMEOUT:    float = 0.8
var current_recouver_time: float = 0.


func _init() -> void:
	state_id = Global.StateID.TRICK_FAIL


@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable_base_class")
func enter(character: CharacterBody2D, payload = null) -> void:
	character.velocity = Vector2.ZERO


func update(_delta: float) -> void:
	pass


func exit() -> void:
	print("")
