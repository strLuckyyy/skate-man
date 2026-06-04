@tool
class_name BTPlayRandomTrick
extends BTRandom

const TRICK_BUFFER_SIZE: int = 3
var _is_executing_trick: bool = false

var _decision:      Global.AIDecision
var _trick_pool:    Array[TrickData]
var _trick_buffer:  Array[TrickData]


func _enter() -> void:
	await agent.ready
	super._enter()
	_is_executing_trick = false
	_current_state      = _char.state_machine.get_current_state_id()
	_trick_pool         = _char.equipment.get_trick_pool(_current_state)
	
	if _trick_pool.is_empty(): return


func _tick(_delta: float) -> Status:
	if not state_check: return FAILURE
	
	if _is_executing_trick:
		if _char.trick_system.is_busy:
			return RUNNING
		else:
			_is_executing_trick = false
			return SUCCESS
	
	# AI decides what it'll do
	_decision = randomize_dicision()
	
	# Nothing Decision
	if _decision == Global.AIDecision.NOTHING:
		return SUCCESS if action_state == Global.StateID.ON_FLOOR else FAILURE
	
	# Jump Decision
	if _decision == Global.AIDecision.JUMP:
		return SUCCESS if _char.apply_jump() else FAILURE
	
	# Trick Decision
	if _decision == Global.AIDecision.TRICK:
		_char.make_trick(randomize_trick())
		return RUNNING if _char.trick_system.is_busy else FAILURE
	return FAILURE


func randomize_trick() -> Array[Global.Direction]:
	if _trick_pool.is_empty():
		return []
	
	var rand_result: int = randi() % _trick_pool.size()
	var trick: TrickData = _trick_pool[rand_result]
	
	if not _trick_buffer.is_empty() and trick in _trick_buffer:
		rand_result = randi() % _trick_pool.size()
		trick = _trick_pool[rand_result]
	
	if _trick_buffer.size() == TRICK_BUFFER_SIZE:
		_trick_buffer.pop_front()
	_trick_buffer.append(trick)
	
	return trick.sequence
