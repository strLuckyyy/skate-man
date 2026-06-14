@tool
class_name BTUpdateAIGoal
extends BTAction

@export var target_goal: Global.AIGoal = Global.AIGoal.CRUISE
var randomizer: Randomizer


func _setup() -> void:
	if agent:
		randomizer = agent.get_node("Randomizer")

 
func _tick(_delta: float) -> Status:
	if not agent or not randomizer:
		return FAILURE
	
	var context: Dictionary = {}
	context["speed"] = agent.velocity.length()
	context["is_airborne"] = not agent.is_on_floor()
	
	var rail_detector = agent.get_node_or_null("Sensors/RailDetector")
	var ramp_detector = agent.get_node_or_null("Sensors/RampDetector")
	
	context["rail_ahead"] = rail_detector.is_colliding() if rail_detector else false
	context["ramp_ahead"] = ramp_detector.is_colliding() if ramp_detector else false
	
	randomizer.current_goal = target_goal
	
	var decision: Global.AIDecision = randomizer.get_decision(context)
	
	agent.execute_decision(decision)
	return SUCCESS
