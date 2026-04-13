class_name BaseEquipament
extends Node

@export var character: BaseCharacter
@export var state_machine: StateMachine
@export var data: EquipamentData


func _ready() -> void:
	var maneuver_nodes: Array[Maneuver]
	maneuver_nodes.assign(get_children())
	
	for m in maneuver_nodes:
		for state in state_machine.states:
			if state.id in m.allowed_state_ids:
				for trick in m.maneuvers:
					state.combo_trie.insert(trick.combo_recipe, trick.method_name)


func on_direction_received(input_dir: Utils.Direction) -> void:
	if state_machine.current_state:
		state_machine.current_state.process_input(input_dir)
