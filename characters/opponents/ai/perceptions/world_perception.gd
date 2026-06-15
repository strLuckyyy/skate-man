class_name WorldPerception
extends Area2D

@onready var ai_agent: OpponentAI = owner
@onready var blackboard: Blackboard = owner.get_node("BTPlayer").get_blackboard()


func _check_body(body: Node2D, value: bool):
	if body is BasePlatform: 
		blackboard.set_value("has_plataform_ahead", value)
	if body is GrindableObject:
		blackboard.set_value("has_rail_ahead",      value)
	if body is RampArea:
		blackboard.set_value("has_ramp_ahead",      value)


func _on_body_entered(body: Node2D) -> void:
	_check_body(body, true)
	print(body.name)


func _on_body_exited(body: Node2D) -> void:
	_check_body(body, false)
	print(body.name)
