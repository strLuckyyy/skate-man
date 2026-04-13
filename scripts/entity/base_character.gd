class_name BaseCharacter
extends CharacterBody2D

@export var stats: StatsData
@export var state_machine: StateMachine
@export var equipment: BaseEquipament

var direction: float = 0.
var fall_current_time: float = 0.


func _ready() -> void:
	state_machine.set_state(Utils.StateID.ON_FLOOR)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		fall_current_time += delta
		if fall_current_time < stats.falling_timeout:
			state_machine.set_state(Utils.StateID.ON_AIR)
		else:
			state_machine.set_state(Utils.StateID.FALLING)
	else:
		state_machine.set_state(Utils.StateID.ON_FLOOR)
		fall_current_time = 0.
	
	move_and_slide()


func apply_movement() -> Vector2:
	return Vector2.ZERO


func apply_jump() -> void:
	pass
