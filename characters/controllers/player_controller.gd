class_name PlayerController 
extends BaseController

@export var input_deadzone := 0.1


# --- Automatic Movement ---
var _auto_move_velocity: float = 0.0
var _auto_move_active:   bool  = false

func get_auto_move_active() -> bool: return _auto_move_active

func set_auto_move_left(speed: float) -> void:
	_auto_move_velocity = -abs(speed)
	_auto_move_active   = true

func set_auto_move_right(speed: float) -> void:
	_auto_move_velocity = abs(speed)
	_auto_move_active   = true

func clear_auto_move() -> void:
	_auto_move_active   = false
	_auto_move_velocity = 0.0

# ---------------------------------------------------------------------------
# Movement methods
# ---------------------------------------------------------------------------

func apply_auto_movement(velocity: Vector2, equipment: EquipmentData, boost: float) -> Vector2:
	var accel = clamp(
		equipment.acceleration * get_physics_process_delta_time(),
		0.0, 1.0
	)
	velocity.x = lerp(velocity.x, _auto_move_velocity + boost, accel)
	return velocity


func apply_movement(velocity: Vector2, equipment: EquipmentData, boost: float) -> Vector2:
	var direction = Input.get_axis("move_left", "move_right")
	var target_speed = direction * equipment.max_speed + boost
	
	var accel = clamp(equipment.acceleration * get_physics_process_delta_time(), 0.0, 1.0)
	var friction = clamp(equipment.friction * get_physics_process_delta_time(), 0.0, 1.0)
	
	if abs(direction) > input_deadzone:
		velocity.x = lerp(velocity.x, target_speed, accel)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	
	return velocity


func apply_jump(velocity: Vector2, equipment_data: EquipmentData) -> Vector2:
	if Input.is_action_just_pressed("jump") and can_jump and jumped == 0:
		jumped    += 1
		is_jumping = true
		velocity.y = -equipment_data.jump_modifier
	return velocity
