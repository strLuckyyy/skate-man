class_name OpponentAI
extends BaseCharacter

signal trick_sequence(candidates: Array[BaseTrick], path: Array[Global.Direction])

@onready var behavior_tree:    BTPlayer        = %BTPlayer
@onready var randomizer:       Randomizer      = %Randomizer
@onready var world_perception: WorldPerception = %WorldPerception

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
	behavior_tree.blackboard.set_var("can_grind", c)
	return c


func make_trick(sequence: Array[Global.Direction]) -> void:
	trick_sequence.emit(equipment.get_tricks(), sequence)


func _push_time(delta: float):
	if _can_push: return
	_push_elapsed += delta
	
	if _push_elapsed >= _push_cd: 
		_can_push = true
		_push_elapsed = 0.0


func apply_push() -> void:
	if not _can_push: return
	if not controller.can_move: return
	velocity = controller.apply_push(velocity, equipment.current_equipment, current_boost_speed)


func apply_jump(_payload: float = 1.0) -> void:
	var pl: float = _payload if _payload > 0.0 else 1.0
	var pre_vel: float = velocity.y
	
	velocity = controller.apply_jump(velocity, equipment.current_equipment) * pl
	_jumped  = false if pre_vel == velocity.y else true


func get_caught() -> void:
	super.get_caught()


func _update_blackboard():
	var bb = behavior_tree.blackboard
	var current_state = state_machine.get_current_state_id()
	
	# --- on air ---
	var oa = current_state in _air_states
	if _on_air != oa: _on_air = oa
	
	bb.set_var("on_air", _on_air)
	bb.set_var("speed", velocity.x)
	
	if world_perception.closer_area != null:
		var area = world_perception.closer_area
		var bb_name = world_perception.get_closer_area_bb_var_name()
		var new_position = abs(area.global_position.x - global_position.x)
		
		bb.set_var(bb_name, new_position)
