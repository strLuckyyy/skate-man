class_name ScoreManager
extends Node2D

signal score_updated(score: float, combo_amount: int)

const TIME    := 6.
var current_time := 6.

var combo_amount := 0
var score        := 0.

var character: BaseCharacter


func get_time_percent() -> float:
	if current_time == 0.0: return current_time
	return inverse_lerp(0.0, TIME, current_time) * 100


func setup(base_character: BaseCharacter) -> void:
	character = base_character
	character.trick_system.trick_started.connect(_trick_detected)
	EventBus.trick_failed.connect(_trick_fail)


func _physics_process(delta: float) -> void:
	if current_time == 0.: return
	if combo_amount == 0:  return
	
	current_time -= delta
	
	if current_time <= 0.:
		current_time = 0.
		combo_amount = 0
		score_updated.emit(score, combo_amount)


func _trick_detected(trick: BaseTrick) -> void:
	score += trick.trick_data.score_bonus
	combo_amount += 1
	current_time = TIME
	
	score_updated.emit(score, combo_amount)


@warning_ignore("unused_parameter")
func _trick_fail(base_character: BaseCharacter, trick: BaseTrick):
	if base_character == character:
		score /= 2
		combo_amount = 0
		current_time = 0.
		
		score_updated.emit(score, combo_amount)


func end_race() -> void:
	EventBus.race_ended.emit(character, score)
