class_name State
extends Node


@export var id: Utils.StateID
var character: BaseCharacter
var combo_trie: Trie = Trie.new()
var current_node: ComboNode


func enter(_character: BaseCharacter) -> void:
	character = _character
	reset_combo()


func exit() -> void:
	pass


func update(delta: float) -> void:
	pass


func process_input(dir: Utils.Direction) -> void:
	if character.sprite.flip_h == true:
		if dir == Utils.Direction.RIGHT: dir = Utils.Direction.LEFT
		elif dir == Utils.Direction.LEFT: dir = Utils.Direction.RIGHT
	
	if current_node.children.has(dir):
		current_node = current_node.children[dir]
		if character.can_maneuver:
			if current_node.action.is_valid():
				current_node.action.call()
				
				character.can_maneuver = false
				character.maneuver_timeout = current_node.cd
				
				reset_combo()
	else:
		reset_combo()


func reset_combo() -> void:
	current_node = combo_trie.root
