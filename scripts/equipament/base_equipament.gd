class_name BaseEquipament
extends Node

@export var character: BaseCharacter
@export var state_machine: StateMachine
@export var data: EquipamentData


func _ready() -> void:
	await owner.ready
	var maneuver_nodes: Array[Maneuver]
	var state_allowed = []
	maneuver_nodes.assign(get_children())
	
	for m:Maneuver in maneuver_nodes:
		m.character = character
		for trick in m.maneuvers:
			for state:State in state_machine.states:
				if state.id in trick.state_allowed:
					state.combo_trie.insert(trick.combo_recipe, trick.method_name, trick.cd_timeout)
