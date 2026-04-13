
class_name Trie
extends RefCounted

var root: ComboNode = ComboNode.new()


func insert(combo: Array[Utils.Direction], method: Callable) -> void:
	var current = root
	for direction in combo:
		if not current.children.has(direction):
			current.children[direction] = ComboNode.new()
		current = current.children[direction]
	current.action = method
