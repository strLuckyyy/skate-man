class_name Player
extends BaseCharacter


func apply_movement() -> Vector2:
	direction = Input.get_axis("move_left", "move_right")
	
	var target_speed = direction * equipment.data.max_speed
	
	if direction != 0.:
		velocity.x = lerp(velocity.x, float(target_speed), equipment.data.acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, equipment.data.friction)
	
	return velocity


func apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = equipment.data.jump_velocity
