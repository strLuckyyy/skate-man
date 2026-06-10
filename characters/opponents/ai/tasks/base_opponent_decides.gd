@abstract
class_name BaseOpponentDecides
extends BTAction

var _char:               OpponentAI
@warning_ignore("unused_private_class_variable")
var _randomizer:         Randomizer
@warning_ignore("unused_private_class_variable")
var _current_state:      Global.StateID
@warning_ignore("unused_private_class_variable")
var _decision:           Global.AIDecision
@warning_ignore("unused_private_class_variable")
var _trick_pool:         Array[TrickData]
@warning_ignore("unused_private_class_variable")
var _trick_buffer:       Array[TrickData]
@warning_ignore("unused_private_class_variable")
var _is_executing_trick: bool


func _enter() -> void:
	_char = agent as OpponentAI
	if _char == null:
		push_error("BTPlayer: O agente configurado não herda de OpponentAI.")
		return


func _check() -> bool: return false
