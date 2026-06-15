@tool
class_name BTActionCruise
extends SetAIGoal


var _push_cd:   float = 0.0


func _enter() -> void:
	super._enter()
	goal = Global.AIGoal.CRUISE
	if _decision == Global.AIDecision.JUMP: _char.apply_jump()


func _tick(delta: float) -> Status:
	if _push_cd > 0.0: _push_cd -= delta
	return apply_cruise()


func apply_cruise() -> Status:
	if _decision == Global.AIDecision.TRICK and not _char.trick_system.is_busy:
		if force_decision != Global.AIDecision.TRICK:
			var result = randi() % 10
			if result < 4: _char.make_trick(_randomizer.randomize_trick(_trick_pool))
			return SUCCESS
		_char.make_trick(_randomizer.randomize_trick(_trick_pool))
		return SUCCESS
	
	if _push_cd <= 0.0:
		_char.apply_push()
		if force_decision == Global.AIDecision.NOTHING: _push_cd = .4
		else: _push_cd = 1.
	
	return SUCCESS
