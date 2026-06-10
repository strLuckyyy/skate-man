class_name OpponentAI
extends BaseCharacter

signal trick_sequence(candidates: Array[BaseTrick], path: Array[Global.Direction])

@onready var behavior_tree: BTPlayer = %BTPlayer

var _on_air:        bool
var _air_states:    Array[Global.StateID] = [Global.StateID.ON_AIR, Global.StateID.ON_FALLING]

func _ready() -> void:
	super._ready()
	trick_system.setup(self, equipment, character_animator, trick_sequence)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
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


func apply_movement(direction: float) -> void:
	controller.direction = direction
	velocity = controller.apply_movement(velocity, equipment.current_equipment, current_boost_speed)


func apply_jump() -> bool:
	var pre_vel: float = velocity.y
	velocity = controller.apply_jump(velocity, equipment.current_equipment)
	if pre_vel == velocity.y:
		return false
	return true


func get_caught() -> void:
	super.get_caught()


func _set_on_air():
	var cs = state_machine.get_current_state_id()
	var oa = cs in _air_states
	
	if _on_air == oa: return
	
	_on_air = oa
	behavior_tree.blackboard.set_var("on_air", _on_air)
