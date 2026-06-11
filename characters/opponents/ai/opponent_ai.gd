class_name OpponentAI
extends BaseCharacter

signal trick_sequence(candidates: Array[BaseTrick], path: Array[Global.Direction])

@onready var behavior_tree: BTPlayer = %BTPlayer

var _jumped:     bool
var _on_air:     bool
var _air_states: Array[Global.StateID] = [Global.StateID.ON_AIR, Global.StateID.ON_FALLING]

func was_jumped() -> bool: return _jumped


func _ready() -> void:
	super._ready()
	trick_system.setup(self, equipment, character_animator, trick_sequence)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	controller.update_moving_state(velocity)
	
	trick_system.process(
		state_machine.get_current_state_id(),
		can_grind(),
		available_grindable
	)
	
	_set_on_air()
	move_and_slide()


func can_grind() -> bool:
	var c: bool = true if available_grindable != null else false
	behavior_tree.blackboard.set_var("can_grind", c)
	return c


func make_trick(sequence: Array[Global.Direction]) -> void:
	trick_sequence.emit(equipment.get_tricks(), sequence)


func apply_push() -> void:
	if not controller.can_move: return
	controller.apply_push(velocity, equipment.current_equipment)


func apply_jump(_payload = null) -> void:
	var pl: float = _payload if (_payload is float and _payload > 0.0) else 1.0
	var pre_vel: float = velocity.y
	
	velocity = controller.apply_jump(velocity, equipment.current_equipment) * pl
	_jumped  = false if pre_vel == velocity.y else true


func get_caught() -> void:
	super.get_caught()


func _set_on_air():
	var cs = state_machine.get_current_state_id()
	var oa = cs in _air_states
	
	if _on_air == oa: return
	
	_on_air = oa
	behavior_tree.blackboard.set_var("on_air", _on_air)
