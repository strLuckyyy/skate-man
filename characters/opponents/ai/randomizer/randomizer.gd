class_name Randomizer
extends RefCounted

const DEBUG := true

var _config:        RandomizerConfig
var _action_buffer: WeightedBuffer
var _trick_buffer:  WeightedBuffer


func setup(config: RandomizerConfig) -> void:
	_config = config
	_action_buffer = WeightedBuffer.new(
		_config.action_penalty_weights.size(),
		_config.action_penalty_weights
	)
	_trick_buffer = WeightedBuffer.new(
		_config.trick_penalty_weights.size(),
		_config.trick_penalty_weights
	)


func randomize_decision() -> Global.AIDecision:
	var pool: Array[Global.AIDecision] = [
		Global.AIDecision.NOTHING,
		Global.AIDecision.JUMP,
		Global.AIDecision.TRICK,
	]
	
	var base: Array[float] = [
		_config.nothing_weight,
		_config.jump_weight  + _config.difficulty_weight,
		_config.trick_weight + _config.difficulty_weight,
	]
	
	# Penalidade de ação recente sobre cada decisão
	var weighted: Array[float] = []
	for i in pool.size():
		var idx := _action_buffer._buffer.find(pool[i])
		var factor := 1.0
		if idx >= 0 and idx < _config.action_penalty_weights.size():
			factor = _config.action_penalty_weights[idx] / 100.0
		weighted.append(base[i] * factor)
	
	var decision: Global.AIDecision = _action_buffer._roll(pool, weighted)
	_action_buffer.push(decision)
	
	_dbg("Decision Buffer -> %s" % _p_buffer(_action_buffer))
	_dbg("Decision → %s" % Global.AIDecision.find_key(decision))
	return decision


func randomize_trick(trick_pool: Array[TrickData]) -> Array[Global.Direction]:
	if trick_pool.is_empty():
		return []
	
	var chosen: TrickData = _trick_buffer.pick_weighted(trick_pool)
	_trick_buffer.push(chosen)
	
	_dbg("Trick Buffer -> %s" % _p_buffer(_trick_buffer))
	_dbg("Trick → %s" % chosen.trick_name)
	return chosen.sequence


func _p_buffer(bffr: WeightedBuffer) -> String:
	return str(bffr._buffer)


func _dbg(msg: String) -> void:
	if DEBUG: print("[Randomizer] ", msg)
