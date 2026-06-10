class_name Randomizer
extends Node


class Buffering:
	var buffer:   Array = []
	var size:     int
	var timeout:  float
	var _elapsed: float = 0.0
	
	func _init(p_size: int, p_timeout: float = 1.8) -> void:
		size    = p_size
		timeout = p_timeout
	
	func add(value) -> void:
		if buffer.size() >= size: buffer.pop_front()
		buffer.append(value)
	
	func is_empty() -> bool:
		return buffer.is_empty()
	
	func has(value) -> bool:
		return value in buffer
	
	func update(delta: float) -> void:
		if buffer.is_empty(): return
		_elapsed += delta
		if _elapsed >= timeout:
			buffer.pop_front()
			_elapsed = 0.0


const DEBUG_BT           := false
const TRICK_BUFFER_SIZE  := 3
const ACTION_BUFFER_SIZE := 8

var weights:        Dictionary
var _trick_buffer:  Buffering
var _action_buffer: Buffering


func dbg(msg: String) -> void:
	if DEBUG_BT:
		print("[", name, "] ", msg)


func setup(nothing_chance: float, jump_chance: float, trick_chance: float, difficulty_weight: float):
	weights = {
		Global.AIDecision.NOTHING: (nothing_chance),
		Global.AIDecision.JUMP:    (jump_chance  + difficulty_weight),
		Global.AIDecision.TRICK:   (trick_chance + difficulty_weight),
		"difficulty_weight":       difficulty_weight
	}
	
	_trick_buffer  = Buffering.new(TRICK_BUFFER_SIZE)
	_action_buffer = Buffering.new(ACTION_BUFFER_SIZE)


func _physics_process(delta: float) -> void:
	_trick_buffer. update(delta)
	_action_buffer.update(delta)


func randomize_decision() -> Global.AIDecision:
	var total_weight: int = (
		weights[Global.AIDecision.NOTHING] +
		weights[Global.AIDecision.JUMP] +
		weights[Global.AIDecision.TRICK]
	)
	var rand_result:  int = randi() % total_weight
	
	dbg("=== DECISION ROLL ===")
	dbg("Nothing Weight: %s" % weights["nothing"])
	dbg("Jump Weight: %s"    % weights["jump"])
	dbg("Trick Weight: %s"   % weights["trick"])
	dbg("Total Weight: %s"   % total_weight)
	dbg("Roll: %s"           % rand_result)
	
	if rand_result <= weights.get("nothing"):
		dbg("Result -> NOTHING")
		return Global.AIDecision.NOTHING
	
	if rand_result <= (weights.get("nothing") + weights.get("jump")):
		dbg("Result -> JUMP")
		return Global.AIDecision.JUMP
	
	dbg("Result -> TRICK")
	return Global.AIDecision.TRICK


func randomize_trick(trick_pool: Array[TrickData]) -> Array[Global.Direction]:
	if trick_pool.is_empty():
		dbg("Trick Pool Empty")
		return []
	
	var rand_result: int = randi() % trick_pool.size()
	var trick: TrickData = trick_pool[rand_result]
	
	if not _trick_buffer.is_empty() and _trick_buffer.has(trick):
		rand_result = randi() % trick_pool.size()
		trick = trick_pool[rand_result]
	
	_trick_buffer.add(trick)
	
	return trick.sequence
