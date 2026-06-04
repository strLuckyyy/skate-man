@tool
class_name BTPlayRandomTrick
extends BTAction

@export_category("State")
@export var action_state: Global.StateID

@export_category("Probability")
@export var nothing_chance: int = 5
@export var jump_chance:    int = 5
@export var trick_chance:   int = 5

var _char:          OpponentAI
var _decision:      OpponentGlobal.Decision
var _trick_pool:    Array[TrickData]
var _current_state: Global.StateID


func _enter() -> void:	
	if agent != OpponentAI:
		push_error("Agent must be a OpponentAI, not ", agent.name)
		return
	_char = agent as OpponentAI
	
	_current_state = _char.state_machine.get_current_state_id()
	_trick_pool    = _char.equipment.get_trick_pool(_current_state)
	
	if _trick_pool.is_empty():
		return


func _tick(_delta: float) -> Status:
	if not state_check: return FAILURE
	_decision = randomize_dicision()
	
	# Nothing Decision
	if _decision == OpponentGlobal.Decision.NOTHING:
		return FAILURE
	
	# Jump Decision
	if _decision == OpponentGlobal.Decision.JUMP:
		var check: bool = _char.apply_jump()
		if not check: return RUNNING
	
	# Trick Decision
	var trick_sequence := randomize_trick()
	_char.make_trick(trick_sequence)
	return SUCCESS


func state_check() -> bool:
	if _current_state != action_state:
		return false
	return true


func randomize_trick() -> Array[Global.Direction]:
	return []


func randomize_dicision() -> OpponentGlobal.Decision:
	var weights: Dictionary = {
		"nothing": nothing_chance * OpponentGlobal.DIFFICULTY_WEIGHT,
		"jump":    jump_chance    * OpponentGlobal.DIFFICULTY_WEIGHT,
		"trick":   trick_chance   * OpponentGlobal.DIFFICULTY_WEIGHT
	}
	var total_weight: int = weights.get("nothing") + weights.get("jump") + weights.get("trick")
	var rand_result:  int = randi() % total_weight
	
	if rand_result <= nothing_chance:
		return OpponentGlobal.Decision.NOTHING
	
	if rand_result <= (nothing_chance + jump_chance):
		return OpponentGlobal.Decision.JUMP
	
	return OpponentGlobal.Decision.TRICK
