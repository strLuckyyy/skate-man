class_name Randomizer
extends Node

# --- Configuration & State ---
var current_goal: Global.AIGoal = Global.AIGoal.CRUISE

# Cooldowns (Hard Locks)
var jump_cooldown:  float = 0.0
var trick_cooldown: float = 0.0

# Fatigue (Dynamic Weight Reduction: 1.0 = fresh, 0.0 = exhausted)
var action_fatigue: Dictionary = {
	Global.AIDecision.NOTHING: 1.0,
	Global.AIDecision.JUMP: 1.0,
	Global.AIDecision.TRICK: 1.0
}

# Base Weights per Goal (Level 2)
const GOAL_WEIGHTS = {
	Global.AIGoal.CRUISE:       { 
		Global.AIDecision.NOTHING: 80, 
		Global.AIDecision.JUMP: 20, 
		Global.AIDecision.TRICK: 10 
		},
	Global.AIGoal.DO_TRICKS:    { 
		Global.AIDecision.NOTHING: 20, 
		Global.AIDecision.JUMP: 40, 
		Global.AIDecision.TRICK: 40 
		},
	Global.AIGoal.SAFE_LANDING: { 
		Global.AIDecision.NOTHING: 100, 
		Global.AIDecision.JUMP: 0, 
		Global.AIDecision.TRICK: 50 
		},
	Global.AIGoal.GRIND_CHAIN:  { 
		Global.AIDecision.NOTHING: 10, 
		Global.AIDecision.JUMP: 40, 
		Global.AIDecision.TRICK: 50 
		}
}


func _physics_process(delta: float) -> void:
	# Recover Cooldowns
	if jump_cooldown > 0.0: jump_cooldown -= delta
	if trick_cooldown > 0.0: trick_cooldown -= delta
	
	# Recover Fatigue gradually
	for action in action_fatigue:
		action_fatigue[action] = move_toward(action_fatigue[action], 1.0, delta * 0.5)


func randomize_trick(trick_pool: Array[TrickData]) -> Array[Global.Direction]:
	if trick_pool.is_empty():
		return []
	
	var rand_result: int = randi() % trick_pool.size()
	var trick: TrickData = trick_pool[rand_result]
	
	rand_result = randi() % trick_pool.size()
	trick = trick_pool[rand_result]
	
	return trick.sequence


# --- Decision Logic ---
func get_decision(context: Dictionary) -> Global.AIDecision:
	# 1. Start with Goal-based weights
	var weights = GOAL_WEIGHTS[current_goal].duplicate()
	
	# 2. Apply World Context Modifiers (Level 3)
	if context.get("has_rail_ahead", false):
		weights[Global.AIDecision.TRICK] += 50
		weights[Global.AIDecision.JUMP]  += 20
		
	if context.get("has_ramp_ahead", false):
		weights[Global.AIDecision.JUMP] += 60
		
	if context.get("speed", 0.0) < 300.0:
		weights[Global.AIDecision.JUMP] = max(0, weights[Global.AIDecision.JUMP] - 30)
		weights[Global.AIDecision.NOTHING] += 50 # Force cruising to build speed

	# 3. Apply Cooldowns (Hard restrictions)
	if jump_cooldown  > 0.0: weights[Global.AIDecision.JUMP] = 0
	if trick_cooldown > 0.0: weights[Global.AIDecision.TRICK] = 0
	
	# 4. Apply Fatigue (Variety enforcer)
	weights[Global.AIDecision.NOTHING] *= action_fatigue[Global.AIDecision.NOTHING]
	weights[Global.AIDecision.JUMP]    *= action_fatigue[Global.AIDecision.JUMP]
	weights[Global.AIDecision.TRICK]   *= action_fatigue[Global.AIDecision.TRICK]

	# 5. Roll the dice
	return _roll_weighted(weights)


func _roll_weighted(weights: Dictionary) -> Global.AIDecision:
	var total = weights[
		Global.AIDecision.NOTHING] + \
		weights[Global.AIDecision.JUMP] + \
		weights[Global.AIDecision.TRICK
		]
	if total <= 0: return Global.AIDecision.NOTHING
	
	var roll = randf_range(0, total)
	
	if roll <= weights[Global.AIDecision.NOTHING]:
		_apply_cost(Global.AIDecision.NOTHING)
		return Global.AIDecision.NOTHING
		
	if roll <= weights[Global.AIDecision.NOTHING] + weights[Global.AIDecision.JUMP]:
		_apply_cost(Global.AIDecision.JUMP)
		return Global.AIDecision.JUMP
		
	_apply_cost(Global.AIDecision.TRICK)
	return Global.AIDecision.TRICK


func _apply_cost(decision: Global.AIDecision) -> void:
	# Trigger cooldowns and fatigue penalty when an action is selected
	if decision == Global.AIDecision.JUMP:
		jump_cooldown = 1.5
		action_fatigue[Global.AIDecision.JUMP] = 0.1 # Drop weight to 10%
	elif decision == Global.AIDecision.TRICK:
		trick_cooldown = 1.0
		action_fatigue[Global.AIDecision.TRICK] = 0.2
	elif decision == Global.AIDecision.NOTHING:
		action_fatigue[Global.AIDecision.NOTHING] = 0.5
