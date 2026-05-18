class_name StateMachine extends Node

var current_state: BaseState
var states: Dictionary = {}
var character: CharacterBody2D


func _ready() -> void:
	states = {
		Global.StateID.CAUGHT: CaughtState.new(),
		Global.StateID.TRICK_FAIL: TrickFailState.new(),
		Global.StateID.ON_FLOOR: OnFloorState.new(),
		Global.StateID.ON_AIR: OnAirState.new(),
		Global.StateID.ON_FALLING: OnFallingState.new(),
		Global.StateID.ON_GRIDING: OnGridingState.new(),
	}
	
	for state in states.values():
		state.transition_requested.connect(_on_transition_requested)


func setup(p: CharacterBody2D) -> void:
	character = p
	if current_state:
		current_state.exit()
	
	current_state = states.get(Global.StateID.ON_FLOOR)
	current_state.enter(character)


func get_current_state_id() -> Global.StateID:
	if not current_state:
		push_error("Has no current state.")
		return Global.StateID.NONE
	return current_state.state_id


func get_state(state_id: Global.StateID) -> BaseState:
	if not states.has(state_id):
		push_error("State " + str(state_id) + " does not exists. Please check the State Machine's children.")
		return null
	
	return states.get(state_id)


func transition_to(state_id: Global.StateID, payload = null) -> void:
	if state_id == null: 
		push_error("Transition receive state id as null value.")
		return
	if current_state.state_id == state_id: return
	
	var new_state = get_state(state_id)
	if new_state == null:
		return
	
	if current_state: current_state.exit()
	
	current_state = new_state
	current_state.enter(character, payload)


func _on_transition_requested(next_state_id: Global.StateID, payload = null):
	character.input_buffer.consume_buffer()
	transition_to(next_state_id, payload)


func _physics_process(delta):
	if current_state:
		current_state.update(delta)
