class_name OpponentAI
extends BaseCharacter

signal trick_sequence(candidates: Array[BaseTrick], path: Array[Global.Direction])

@onready var behavior_tree: BTPlayer   = %BTPlayer
@onready var randomizer:    Randomizer = %Randomizer

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
	
	_set_on_air()
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


# --- Behavior Tree API ---
func execute_decision(decision: Global.AIDecision) -> void:
	match decision:
		Global.AIDecision.NOTHING:
			apply_push()
		
		Global.AIDecision.JUMP:
			apply_jump()
		
		Global.AIDecision.TRICK:
			var state_id   := state_machine.current_state.state_id
			var trick_pool := equipment.get_trick_pool(state_id)
			make_trick(randomizer.randomize_trick(trick_pool))


func _perform_trick() -> void:
	if not is_on_floor():
		# OPÇÃO A: Chamar seu sistema de trick diretamente
		# var random_trick = trick_system.get_random_available_trick()
		# trick_system.execute(random_trick)
		
		# OPÇÃO B: Usar Input Buffer
		# ai_input_buffer.push_action("kickflip")
		
		print("AI: Mandou uma manobra!")
 

func get_caught() -> void:
	super.get_caught()


func _set_on_air():
	var cs = state_machine.get_current_state_id()
	var oa = cs in _air_states
	
	if _on_air == oa: return
	
	_on_air = oa
	behavior_tree.blackboard.set_var("on_air", _on_air)
