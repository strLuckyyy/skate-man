@tool
class_name IsFeatureAhead
extends BTCondition

@export var check_type: Global.ObstacleType

func _tick(_delta: float) -> Status:
	if agent.obstacles.has(check_type): return SUCCESS
	return FAILURE
