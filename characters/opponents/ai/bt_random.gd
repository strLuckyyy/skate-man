class_name BTRandom
extends BTAction

@export_category("State")
@export var action_state: Global.StateID

@export_category("Probability")
@export var difficulty_weight: float = 6
@export var nothing_chance:    int = 5
@export var jump_chance:       int = 5
@export var trick_chance:      int = 5

var _char:          OpponentAI
var _current_state: Global.StateID


func _enter() -> void:
	if agent != OpponentAI:
		push_error("Agent must be a OpponentAI, not ", agent.name)
		return
	
	_char = agent as OpponentAI


func state_check() -> bool:
	if _current_state != action_state:
		return false
	return true


func randomize_dicision() -> Global.AIDecision:
	var weights: Dictionary = {
		"nothing": (nothing_chance * difficulty_weight),
		"jump":    (jump_chance    * difficulty_weight),
		"trick":   (trick_chance   * difficulty_weight)
	}
	var total_weight: int = weights.get("nothing") + weights.get("jump") + weights.get("trick")
	var rand_result:  int = randi() % total_weight
	
	if rand_result <= nothing_chance:
		return Global.AIDecision.NOTHING
	
	if rand_result <= (nothing_chance + jump_chance):
		return Global.AIDecision.JUMP
	
	return Global.AIDecision.TRICK
