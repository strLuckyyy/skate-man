class_name Trie
extends RefCounted

var root: ComboNode = ComboNode.new()


func insert(combo: Array[Utils.Direction], method: Callable, cd: float) -> void:
	var current = root
	for direction in combo:
		if not current.children.has(direction):
			current.children[direction] = ComboNode.new()
		current = current.children[direction]
	current.cd = cd
	current.action = method


func _print_() -> void:
	_print_node(root, "", -1)

func _print_node(node: ComboNode, prefix: String, edge_label: int) -> void:
	var action_str = " [" + node.action.get_method() + "]" if node.action.is_valid() else ""
	var edge_str   = Utils.Direction.keys()[edge_label] + " →" if edge_label != -1 else "root"
	print(prefix + edge_str + action_str)

	var keys = node.children.keys()
	for i in keys.size():
		var is_last   = i == keys.size() - 1
		var child_key = keys[i]
		_print_node(node.children[child_key], prefix + ("└─ " if is_last else "├─ "), child_key)
