class_name BoostComponent
extends Node

var character: BaseCharacter
var current_boost: float = 0.0


func setup(p_character: BaseCharacter) -> void:
	character = p_character


func add_boost(amount: float) -> void:
	var max_boost = character.get_max_boost_speed()
	current_boost = clamp(current_boost + amount, 0.0, max_boost)
	character.current_boost_speed = current_boost


func reset_boost() -> void:
	current_boost = 0.0
	character.current_boost_speed = 0.0
