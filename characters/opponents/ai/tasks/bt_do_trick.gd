@tool
class_name BTDoTrick
extends SetAIGoal


func _enter() -> void:
	super._enter()
	goal = Global.AIGoal.DO_TRICKS


func _tick(_delta: float) -> Status:
	return do_trick()


func do_trick() -> Status:
	var sequence := _randomizer.randomize_trick(_trick_pool)
	if _decision == Global.AIDecision.TRICK and not _char.trick_system.is_busy:
		_char.make_trick(sequence)	
	return SUCCESS
