class_name OpponentAI
extends BaseCharacter

signal trick_sequence(candidates: Array[BaseTrick], path: Array[Global.Direction])

@onready var behavior_tree:    BTPlayer          = %BTPlayer
@onready var ai_assessor:      AIAssessor        = %AIAssessor
@onready var ai_perception:    AIPerceptionRadar = %AIPerceptionRadar
@onready var blackboard:       Blackboard        = %BTPlayer.blackboard

@export var profile_data: AIProfileData = null

# --- push controll ---
var _can_push:     bool  = true
var _push_cd:      float = 1.
var _push_elapsed: float = 0.0

var _jumped:     bool
var _on_air:     bool
var _air_states: Array[Global.StateID] = [Global.StateID.ON_AIR, Global.StateID.ON_FALLING]

func was_jumped() -> bool:  return _jumped


func _ready() -> void:
	super._ready()
	trick_system.setup(self, equipment, character_animator, trick_sequence)
	if ai_assessor: ai_assessor.setup(profile_data)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_push_time(delta)
	
	controller.update_moving_state(velocity)
	
	trick_system.process(
		state_machine.get_current_state_id(),
		can_grind(),
		available_grindable
	)
	
	_update_blackboard()
	state_machine.process_physics(delta)
	move_and_slide()


func can_grind() -> bool:
	var c: bool = true if available_grindable != null else false
	blackboard.set_var("can_grind", c)
	return c


func make_trick(sequence: Array[Global.Direction]) -> void:
	trick_sequence.emit(equipment.get_tricks(), sequence)


func _push_time(delta: float):
	if _can_push: return
	_push_elapsed += delta
	
	if _push_elapsed >= _push_cd: 
		_can_push = true
		_push_elapsed = 0.0


func apply_push(forced := false) -> void:
	if not forced:
		if not _can_push: return
	velocity = controller.apply_push(velocity, equipment.current_equipment, current_boost_speed, forced)


func apply_jump(_payload: float = 1.0) -> void:
	var pl: float = _payload if _payload > 0.0 else 1.0
	var pre_vel: float = velocity.y
	
	velocity = controller.apply_jump(velocity, equipment.current_equipment) * pl
	_jumped  = false if pre_vel == velocity.y else true


func get_caught() -> void:
	super.get_caught()


func _update_blackboard() -> void:
	if not blackboard or not is_instance_valid(ai_perception):
		return
	
	var current_state = state_machine.get_current_state_id()
	
	var is_on_air = current_state in _air_states
	if _on_air != is_on_air: _on_air = is_on_air
	var dist_to_rail = ai_perception.get_distance_to_nearest_type(Global.TargetType.RAIL)
	
	blackboard.set_var("rail_distance", dist_to_rail)
	blackboard.set_var("on_air", _on_air)
	blackboard.set_var("speed", velocity.x)
	blackboard.set_var("can_grind", available_grindable != null)
	
	# O Radar alimenta o Blackboard diretamente
	if is_instance_valid(ai_perception):
		blackboard.set_var(Global.BBKeys.NEAREST_TARGET_TYPE, ai_perception.nearest_type)
		blackboard.set_var(Global.BBKeys.NEAREST_TARGET_DIST, ai_perception.nearest_distance)
		blackboard.set_var(Global.BBKeys.NEAREST_TARGET_NODE, ai_perception.nearest_target)
		blackboard.set_var(Global.BBKeys.HAS_TARGET_AHEAD, ai_perception.nearest_type != Global.TargetType.NONE)
