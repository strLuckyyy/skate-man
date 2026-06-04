class_name AIController
extends BaseController

var direction: float = 0.0


func apply_movement(velocity: Vector2, equipment: EquipmentData, boost: float) -> Vector2:
	if not can_move: return velocity
	
	var target_speed = direction * equipment.max_speed + boost
	
	var accel    = clamp(equipment.acceleration * get_physics_process_delta_time(), 0.0, 1.0)
	var friction = clamp(equipment.friction * get_physics_process_delta_time(),     0.0, 1.0)
	
	if abs(direction) > 0: velocity.x = lerp(velocity.x, target_speed, accel)
	else:                  velocity.x = lerp(velocity.x, 0.0, friction)
	return velocity


func apply_jump(velocity: Vector2, equipment_data: EquipmentData) -> Vector2:
	if can_jump and jumped == 0:
		jumped    += 1
		is_jumping = true
		velocity.y = -equipment_data.jump_modifier
	return velocity
