@tool
class_name BTSafeLanding
extends SetAIGoal


func _enter() -> void:
	super._enter()
	goal = Global.AIGoal.SAFE_LANDING


func _tick(_delta: float) -> Status:
	return safe_landing()


func safe_landing() -> Status:
	if _char.is_on_floor(): return SUCCESS
	return RUNNING
