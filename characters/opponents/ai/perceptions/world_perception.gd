class_name WorldPerception
extends Area2D

@onready var _ai_agent: OpponentAI = owner
@onready var _blackboard: Blackboard = owner.get_node("BTPlayer").get_blackboard()

var closer_area: Area2D = null

func get_closer_area_bb_var_name() -> String:
	if closer_area is RampArea:
		return "ramp_distance"
	elif closer_area is GrindArea:
		return "rail_distance"
	elif closer_area is WaitingArea:
		return "plataform_distance"
	else:
		return ""


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _check_area(area: Area2D, value: bool) -> void:
	var calc = abs(area.global_position.x - _ai_agent.global_position.x) if value else null
	closer_area = area if value else null
	
	if area is RampArea:
		_blackboard.set_var("has_ramp_ahead", value)
		_blackboard.set_var("ramp_distance",   calc)
	elif area is GrindArea:
		_blackboard.set_var("has_rail_ahead", value)
		_blackboard.set_var("rail_distance",   calc)
	elif area is WaitingArea:
		_blackboard.set_var("has_plataform_ahead", value)
		_blackboard.set_var("plataform_distance",   calc)


func _on_area_entered(area: Area2D) -> void:
	_check_area(area, true)

func _on_area_exited(area: Area2D) -> void:
	_check_area(area, false)
