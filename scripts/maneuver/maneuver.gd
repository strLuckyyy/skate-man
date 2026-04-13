class_name Maneuver
extends Node2D

@export var allowed_states_ids: Array[Utils.StateID]
var maneuvers: Array[TrickInfo]
var maneuver_trie: Trie


func _ready() -> void:
	pass


func print_manouver():
	for i in maneuvers:
		i.debug_print()


func get_manouver_info() -> Array[Utils.Direction]:
	var arr: Array
	for i in maneuvers:
		arr.append([i.combo_recipe, i.method_name])
	return arr
