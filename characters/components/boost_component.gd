class_name BoostComponent
extends Node

signal boost_update(update_boost_value: float)

var character:     BaseCharacter
var current_boost: float = 0.0

func setup(p_character: BaseCharacter) -> void:
	character = p_character

func add_boost(amount: float) -> void:
	var max_boost := character.get_max_boost_speed()
	current_boost = clamp(current_boost + amount, 0.0, max_boost)
	boost_update.emit(current_boost)

func reset_boost() -> void:
	current_boost = 0.0
	boost_update.emit(current_boost)
