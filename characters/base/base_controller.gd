class_name BaseController
extends Node2D

var is_locked:     bool = false
var is_trick_fail: bool = false
var can_jump:      bool = true
var can_move:      bool = true
var is_jumping:    bool = false
var is_moving:     bool = false
var jumped:        int  = 0

func reset_jumped() -> void: jumped = 0


func update_moving_state(velocity: Vector2) -> void:
	is_moving = abs(velocity.x) > 1.0


func apply_gravity(delta: float, character: BaseCharacter) -> void:
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	else:
		character.is_jumping = false
		character.jumped     = 0


@warning_ignore("unused_parameter")
func apply_movement(
	velocity: Vector2, equipment: EquipmentData, boost: float)    -> Vector2: return velocity
@warning_ignore("unused_parameter")
func apply_jump(velocity: Vector2, equipment_data: EquipmentData) -> Vector2: return velocity
