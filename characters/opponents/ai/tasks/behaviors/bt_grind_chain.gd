@tool
class_name BTGrindChain
extends SetAIGoal


func _enter() -> void:
	super._enter()
	goal = Global.AIGoal.GRIND_CHAIN


func _tick(_delta: float) -> Status:
	return grind_chain()


func grind_chain() -> Status:
	var rail_dist = blackboard.get_var("rail_distance")
	if  rail_dist != null and rail_dist > 10:
		_char.apply_push()
		return RUNNING
	
	var sequence := ai_assessor.get_random_trick(_trick_pool, true)
	if _char.can_grind() and not _char.trick_system.is_busy:
		if _char.is_on_floor(): _jump_to_grind(sequence)
		else: _char.make_trick(sequence)
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
