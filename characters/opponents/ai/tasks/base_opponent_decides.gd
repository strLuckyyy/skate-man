@abstract
class_name BaseOpponentDecides
extends BTAction

var _randomizer:         Randomizer
var _char:               OpponentAI
var _current_state:      Global.StateID
var _decision:           Global.AIDecision
var _trick_pool:         Array[TrickData]
var _trick_buffer:       Array[TrickData]
var _is_executing_trick: bool


func _enter() -> void:
	_char = agent as OpponentAI
	if _char == null:
		push_error("BTPlayRandomTrick: agent must be OpponentAI")
		return


func _check() -> bool: return false
