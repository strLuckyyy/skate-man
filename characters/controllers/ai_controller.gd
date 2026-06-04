class_name AIController
extends BaseController


func apply_jump(velocity: Vector2, equipment_data: EquipmentData) -> Vector2:
	if can_jump and jumped == 0:
		jumped    += 1
		is_jumping = true
		velocity.y = -equipment_data.jump_modifier
	return velocity
