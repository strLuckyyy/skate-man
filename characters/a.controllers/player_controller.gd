class_name PlayerController 
extends Node2D

@export var input_deadzone := 0.1

# --- Automatic Movement ---
## While != zero, toggle the directional input to this target speed.
## Use set_auto_move() / clear_auto_move() to controll.
var _auto_move_velocity: float = 0.0
var _auto_move_active:   bool  = false

func get_auto_move_active() -> bool: return _auto_move_active

## Ativa movimento automático para a esquerda.
## speed: velocidade horizontal negativa (ex: -150.0 para esquerda).
func set_auto_move_left(speed: float) -> void:
	_auto_move_velocity = -abs(speed)   # garante direção correta
	_auto_move_active   = true


## Ativa movimento automático para a direita.
func set_auto_move_right(speed: float) -> void:
	_auto_move_velocity = abs(speed)
	_auto_move_active   = true


## Para o movimento automático e devolve o controle ao input.
func clear_auto_move() -> void:
	_auto_move_active   = false
	_auto_move_velocity = 0.0


func apply_auto_movement(equipment: EquipmentData, velocity: Vector2) -> Vector2:
	var accel = clamp(
		equipment.acceleration * get_physics_process_delta_time(),
		0.0, 1.0
	)
	velocity.x = lerp(velocity.x, _auto_move_velocity, accel)
	return velocity


func apply_movement(velocity: Vector2, equipment_data: EquipmentData) -> Vector2:
	var direction = Input.get_axis("move_left", "move_right")
	var target_speed = direction * equipment_data.max_speed
	
	var accel = clamp(equipment_data.acceleration * get_physics_process_delta_time(), 0.0, 1.0)
	var friction = clamp(equipment_data.friction * get_physics_process_delta_time(), 0.0, 1.0)
	
	if abs(direction) > input_deadzone:
		velocity.x = lerp(velocity.x, target_speed, accel)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	
	return velocity


func apply_jump(equipment_data: EquipmentData) -> float:
	return -equipment_data.jump_modifier
