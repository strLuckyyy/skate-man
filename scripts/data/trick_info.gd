class_name TrickInfo
extends Node

var action_id: int
var score_points: int
var is_sustained: bool = false
var balance_difficulty: float = 1.0
var combo_recipe: Array[Utils.Direction]
var need_hold: bool = false
var method_name: Callable

func _init(
	_id: int, 
	_score_points: int, 
	_is_sustained: bool,
	_balance_difficulty: float,
	_combo_recipe: Array[Utils.Direction],
	_need_hold: bool,
	_method: Callable
) -> void:
	action_id = _id
	score_points = _score_points
	is_sustained = _is_sustained
	balance_difficulty = _balance_difficulty
	combo_recipe = _combo_recipe
	need_hold = _need_hold
	method_name = _method


func debug_print():
	print(str(
		action_id, ", ",
		score_points, ", ",
		is_sustained, ", ",
		balance_difficulty, ", ",
		combo_recipe, ", ",
		need_hold, ", ",
		method_name.get_method()
		)
	)
