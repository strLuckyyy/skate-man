@tool
extends BTAction

@export var goal: Global.AIGoal
@export var force_decision: Global.AIDecision = Global.AIDecision.NONE

var _char:          OpponentAI
var _context:       Dictionary
var _randomizer:    Randomizer
var _trick_pool:    Array[TrickData]
var _current_state: Global.StateID
var _decision:      Global.AIDecision

var push_cd:   float = 0.0

func _setup() -> void:
	_randomizer = Randomizer.new()


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


func _tick(delta: float) -> Status:
	_decision = _randomizer.get_decision(_context) if (
		force_decision == Global.AIDecision.NONE) else force_decision
	
	if _decision == Global.AIDecision.JUMP: _char.apply_jump()
	if push_cd > 0.0: push_cd -= delta
	
	match goal:
		Global.AIGoal.CRUISE:
			return cruise()
		Global.AIGoal.DO_TRICKS:
			return tricky()
		Global.AIGoal.SAFE_LANDING:
			return safe_landing()
		Global.AIGoal.GRIND_CHAIN:
			return grind_chain()
	return FAILURE


func cruise() -> Status:	
	if _decision == Global.AIDecision.TRICK and not _char.trick_system.is_busy:
		if force_decision != Global.AIDecision.TRICK:
			var result = randi() % 10
			if result < 4: _char.make_trick(_randomizer.randomize_trick(_trick_pool))
			return RUNNING
		_char.make_trick(_randomizer.randomize_trick(_trick_pool))
		return RUNNING
	
	if push_cd > 0.0: return RUNNING
	_char.apply_push()
	if force_decision == Global.AIDecision.NOTHING: push_cd = .4
	else: push_cd = 1.
	
	return SUCCESS


func tricky() -> Status:
	var sequence := _randomizer.randomize_trick(_trick_pool)
	if _decision == Global.AIDecision.TRICK and not _char.trick_system.is_busy:
		_char.make_trick(sequence)
		return RUNNING
	
	return SUCCESS


func safe_landing() -> Status:
	if _char.is_on_floor(): return SUCCESS
	return RUNNING


func grind_chain() -> Status:
	var sequence := _randomizer.randomize_trick(_trick_pool)
	if _char.can_grind() and not _char.trick_system.is_busy:
		if _char.is_on_floor(): _jump_to_grind(sequence)
		else: _char.make_trick(sequence)
		return RUNNING
	
	return SUCCESS


func _jump_to_grind(sequence: Array[Global.Direction]):
	if force_decision != Global.AIDecision.JUMP or force_decision != Global.AIDecision.TRICK: 
		var result = randi() % 10
		if result < 6: 
			_char.apply_jump()
			_char.make_trick(sequence)
		return
	
	_char.apply_jump()
	_char.make_trick(sequence)
