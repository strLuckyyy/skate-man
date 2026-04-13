class_name StateMachine
extends Node

var current_state: State
var character: BaseCharacter
var states: Array[State]
var last_state: Utils.StateID = Utils.StateID.NONE


func set_state(state_id: Utils.StateID):
	if state_id == last_state: return

	var from = Utils.StateID.keys()[last_state] if last_state != Utils.StateID.NONE else "NONE"
	var to   = Utils.StateID.keys()[state_id]
	print("[SM] %s → %s" % [from, to])

	if current_state: current_state.exit()
	for i: State in states:
		if i.id == state_id:
			current_state = i
			break

	if not current_state:
		push_error("[SM] state não encontrado: " + to)
		return

	current_state.enter(character)
	last_state = state_id


func _ready() -> void:
	await owner.ready
	character = owner
	
	for i in get_children():
		if i is State:
			states.append(i)
	
	if current_state:
		current_state.enter(character)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
