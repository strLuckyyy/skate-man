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


func update(_delta: float) -> void:
	pass


func process_input(dir: Utils.Direction) -> void:
	if current_node.children.has(dir):
		current_node = current_node.children[dir]
		if current_node.action.is_valid():
			current_node.action.call()
			reset_combo()
	else:
		reset_combo()


func reset_combo() -> void:
	current_node = combo_trie.root
