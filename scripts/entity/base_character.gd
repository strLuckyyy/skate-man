class_name BaseCharacter
extends CharacterBody2D

@export var state_machine: StateMachine
@export var equipament: BaseEquipament
@onready var sprite: Sprite2D = $Sprite2D

var direction: float = 0.
var last_direction: float = 0.
var fall_current_time: float = 0.

var maneuver_timeout: float = 0.0
var current_time_cd: float = 0.0
var can_maneuver: bool = true
var method_slide_called = false
var sliding: bool = false

func set_state_to_slide(is_in: bool):
	if is_in: sliding = true
	else: sliding = false

func _physics_process(delta: float) -> void:
	if not can_maneuver:
		current_time_cd += delta
		if current_time_cd >= maneuver_timeout:
			can_maneuver = true
			current_time_cd = 0.0
	
	if not sliding:
		if not is_on_floor():
			velocity += get_gravity() * delta
			
			fall_current_time += delta
			if fall_current_time < equipament.data.falling_timeout:
				state_machine.set_state(Utils.StateID.ON_AIR)
			else:
				state_machine.set_state(Utils.StateID.FALLING)
		else:
			state_machine.set_state(Utils.StateID.ON_FLOOR)
			fall_current_time = 0.
	else:
		state_machine.set_state(Utils.StateID.ON_SLIDE)
	move_and_slide()


func apply_movement() -> Vector2:
	return Vector2.ZERO


func apply_jump() -> void:
	pass


func force_jump() -> void:
	pass


func _update_sprite_direction() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
