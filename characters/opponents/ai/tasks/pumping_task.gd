class_name PumpingTask
extends BTRandom


func _enter() -> void:
	await agent.ready
	super._enter()


func _tick(_delta: float) -> Status:
	if not state_check: return FAILURE
	var decision: Global.AIDecision = randomize_dicision()
	
	if decision == Global.AIDecision.JUMP:
		return SUCCESS if _char.apply_jump() else FAILURE
	
	if decision != Global.AIDecision.JUMP:
		_char.apply_movement(1.0)
		return SUCCESS
	
	return FAILURE
