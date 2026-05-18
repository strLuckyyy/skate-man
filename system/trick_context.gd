class_name TrickContext
extends RefCounted

var _state_id: Global.StateID
var _grind_opportunity: bool
var _input_buffer: Array[Global.Direction]

func get_state_id() -> Global.StateID: return _state_id
func get_grind_opportunity() -> bool: return _grind_opportunity
func get_input_buffer() -> Array[Global.Direction]: return _input_buffer.duplicate()

func build_context(state_id: Global.StateID, grind_opportunity: bool, input_buffer: Array[Global.Direction]) -> void:
	_state_id = state_id
	_grind_opportunity = grind_opportunity
	_input_buffer = input_buffer
