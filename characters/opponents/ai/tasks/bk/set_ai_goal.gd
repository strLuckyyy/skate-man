@tool
class_name SetAIGoal
extends BTAction

var goal: Global.AIGoal
@export var force_decision: Global.AIDecision = Global.AIDecision.NONE

var _char:          OpponentAI
var _context:       Dictionary
var ai_assessor:    AIAssessor
var _trick_pool:    Array[TrickData]
var _current_state: Global.StateID
var _decision:      Global.AIDecision

func _setup() -> void:
	ai_assessor = _char.ai_assessor


func _enter() -> void:
	_char = agent as OpponentAI
	if _char == null:
		push_error("BTPlayer - SetAIGoal: O agente configurado não herda de OpponentAI.")
		return
	_char.controller.can_move = true
	
	_current_state = _char.state_machine.current_state.state_id
	_trick_pool = _char.equipment.get_trick_pool(_current_state)
	
	_context = {
		"has_rail_ahead": blackboard.get_var("has_rail_ahead"),
		"has_ramp_ahead": blackboard.get_var("has_ramp_ahead"),
		"speed":          blackboard.get_var("speed")
	}
	
	_decision = ai_assessor.get_decision(_context) if (
		force_decision == Global.AIDecision.NONE) else force_decision
