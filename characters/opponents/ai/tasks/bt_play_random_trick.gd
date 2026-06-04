@tool
class_name BTPlayRandomTrick
extends BTAction

@export_category("State")
@export var action_state: Global.StateID

@export_category("Probability")
@export var difficulty_weight: float = 6
@export var nothing_chance:    int = 5
@export var jump_chance:       int = 5
@export var trick_chance:      int = 5

const TRICK_BUFFER_SIZE: int = 3
var _is_executing_trick: bool = false

var _char:          OpponentAI
var _current_state: Global.StateID
var _decision:      Global.AIDecision
var _trick_pool:    Array[TrickData]
var _trick_buffer:  Array[TrickData]

const DEBUG_BT := true

func dbg(msg: String) -> void:
	if DEBUG_BT:
		print("[BTPlayRandomTrick] ", msg)

func _enter() -> void:
	await agent.ready
	dbg("=== ENTER ===")
	if agent != OpponentAI:
		push_error("Agent must be a OpponentAI, not ", agent.name)
		return
	_char = agent as OpponentAI
	dbg("Agent: %s" % _char.name)
	
	_is_executing_trick = false
	_current_state      = _char.state_machine.get_current_state_id()
	_trick_pool         = _char.equipment.get_trick_pool(_current_state)
	
	dbg("Current State: %s" % _current_state)
	dbg("Trick Pool Size: %d" % _trick_pool.size())

	for trick in _trick_pool:
		dbg("Pool Trick: %s" % trick.name)
	#if _trick_pool.is_empty(): return


func _tick(_delta: float) -> Status:
	dbg("---------------------")
	dbg("Tick")
	dbg("Current State: %s" % _current_state)
	dbg("Action State: %s" % action_state)
	
	if not state_check(): 
		dbg("State Check FAILED")
		return FAILURE
	dbg("State Check SUCCESS")
	
	if _is_executing_trick:
		dbg("Waiting Trick Execution")
		if _char.trick_system.is_busy:
			dbg("TrickSystem BUSY -> RUNNING")
			return RUNNING
		else:
			dbg("Trick Finished -> SUCCESS")
			_is_executing_trick = false
			return SUCCESS
	
	# AI decides what it'll do
	_decision = randomize_decision()
	
	dbg("Decision: %s" % Global.AIDecision.keys()[_decision])
	
	# Nothing Decision
	if _decision == Global.AIDecision.NOTHING:
		dbg("Executing NOTHING")
		if action_state == Global.StateID.ON_FLOOR:
			_char.apply_movement(1.0)
		return SUCCESS
	
	# Jump Decision
	if _decision == Global.AIDecision.JUMP:
		dbg("Executing JUMP")
		var result := _char.apply_jump()
		dbg("Jump Result: %s" % result)
		return SUCCESS if _char.apply_jump() else FAILURE
	
	# Trick Decision
	if _decision == Global.AIDecision.TRICK:
		dbg("Executing TRICK")
		_char.make_trick(randomize_trick())
		return RUNNING if _char.trick_system.is_busy else FAILURE
	dbg("Unexpected FAILURE")
	return FAILURE


func state_check() -> bool:
	_current_state = _char.state_machine.get_current_state_id()
	if _current_state != action_state:
		return false
	return true


func randomize_decision() -> Global.AIDecision:
	var weights: Dictionary = {
		"nothing": (nothing_chance),
		"jump":    (jump_chance  + difficulty_weight),
		"trick":   (trick_chance + difficulty_weight)
	}
	var total_weight: int = weights.get("nothing") + weights.get("jump") + weights.get("trick")
	var rand_result:  int = randi() % total_weight
	
	dbg("=== DECISION ROLL ===")
	dbg("Nothing Weight: %s" % weights["nothing"])
	dbg("Jump Weight: %s" % weights["jump"])
	dbg("Trick Weight: %s" % weights["trick"])
	dbg("Total Weight: %s" % total_weight)
	dbg("Roll: %s" % rand_result)
	
	if rand_result <= weights.get("nothing"):
		dbg("Result -> NOTHING")
		return Global.AIDecision.NOTHING
	
	if rand_result <= (weights.get("nothing") + weights.get("jump")):
		dbg("Result -> JUMP")
		return Global.AIDecision.JUMP
	
	dbg("Result -> TRICK")
	return Global.AIDecision.TRICK


func randomize_trick() -> Array[Global.Direction]:
	if _trick_pool.is_empty():
		dbg("Trick Pool Empty")
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
