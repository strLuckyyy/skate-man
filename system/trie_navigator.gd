class_name TrieNavigator
extends Node

class TrieNode:
	var children: Dictionary = {}
	var tricks:   Array[BaseTrick] = []

	func is_leaf() -> bool:
		return children.is_empty()

	func has_trick() -> bool:
		return not tricks.is_empty()


signal sequence_resolved(candidates: Array[BaseTrick], path: Array[Global.Direction])

const COMMIT_WINDOW: float = 0.2

var _root:         TrieNode
var _current_node: TrieNode
var _current_path: Array[Global.Direction] = []
var _commit_timer: Timer


func _ready() -> void:
	_root         = TrieNode.new()
	_current_node = _root

	_commit_timer           = Timer.new()
	_commit_timer.one_shot  = true
	_commit_timer.wait_time = COMMIT_WINDOW
	_commit_timer.timeout.connect(_on_commit_timeout)
	add_child(_commit_timer)


func setup(input_buffer: InputBuffer, equipment_manager: EquipmentManager) -> void:
	input_buffer.direction_input.connect(_on_direction_input)
	equipment_manager.equipment_changed.connect(_on_equipment_changed)


func rebuild(tricks: Array[BaseTrick]) -> void:
	_root = TrieNode.new()
	for trick in tricks:
		if trick.trick_data == null or trick.trick_data.sequence.is_empty():
			continue
		_insert_trick(trick)
	reset()


func reset() -> void:
	_current_node = _root
	_current_path.clear()
	_commit_timer.stop()


func _on_equipment_changed(_equipment: EquipmentData, tricks: Array[BaseTrick]) -> void:
	rebuild(tricks)


func _on_direction_input(direction: Global.Direction, pressed: bool) -> void:
	if not pressed: return
	_advance(direction)


func _advance(direction: Global.Direction) -> void:
	_commit_timer.stop()
	
	if _current_node.children.has(direction):
		_current_node = _current_node.children[direction]
		_current_path.append(direction)
	else:
		reset()
		if not _root.children.has(direction):
			return
		_current_node = _root.children[direction]
		_current_path.append(direction)
	
	if not _current_node.has_trick():
		return
	
	if _current_node.is_leaf():
		_resolve()
	else:
		_commit_timer.start()


func _on_commit_timeout() -> void:
	_resolve()


func _resolve() -> void:
	if _current_node == null or not _current_node.has_trick():
		reset()
		return
	
	sequence_resolved.emit(
		_current_node.tricks.duplicate(),
		_current_path.duplicate()
	)
	reset()


func _insert_trick(trick: BaseTrick) -> void:
	var node := _root
	for dir: int in trick.trick_data.sequence:
		if not node.children.has(dir):
			node.children[dir] = TrieNode.new()
		node = node.children[dir]
	node.tricks.append(trick)
