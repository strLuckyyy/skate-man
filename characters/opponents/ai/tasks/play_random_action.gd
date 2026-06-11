@tool
extends BaseOpponentDecides

@export_category("State")
@export var action_state: Global.StateID

@export_category("Probability")
@export var config: RandomizerConfig

func _setup() -> void:
	_randomizer = Randomizer.new()


func _enter() -> void:
	super._enter()
	_trick_pool         = _char.equipment.get_trick_pool(action_state)
	_is_executing_trick = false
	_randomizer.setup(config)
	_char.controller.can_move = true


func _tick(_delta: float) -> Status:
	if not _check():
		return FAILURE
	
	_current_state = _char.state_machine.get_current_state_id()
	
	if _is_executing_trick:
		if _char.trick_system.is_busy:
			return RUNNING
		else:
			_is_executing_trick = false
			return SUCCESS
	
	# AI decides what it'll do
	_decision = _randomizer.randomize_decision()
	
	match _decision:
		Global.AIDecision.NOTHING:
			if action_state == Global.StateID.ON_FLOOR:
				_char.apply_push(); return RUNNING
		
		Global.AIDecision.JUMP:
			return SUCCESS if _char.was_jumped() else FAILURE
		
		Global.AIDecision.TRICK:
			if _trick_pool.is_empty(): return FAILURE
			_char.make_trick(_randomizer.randomize_trick(_trick_pool))
			if _char.trick_system.is_busy:
				_is_executing_trick = true; return RUNNING
			return FAILURE
	return FAILURE


func _check() -> bool:
	if _char == null or not is_instance_valid(_char):              return false
	if _char.state_machine == null:                                return false
	if _char.state_machine.get_current_state_id() != action_state: return false
	return true
