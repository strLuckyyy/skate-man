class_name Player
extends BaseCharacter

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		state_machine.current_state.process_input(Utils.Direction.UP)
	if event.is_action_pressed("down"):
		state_machine.current_state.process_input(Utils.Direction.DOWN)
	if event.is_action_pressed("left"): 
		state_machine.current_state.process_input(Utils.Direction.LEFT)
	if event.is_action_pressed("right"):
		state_machine.current_state.process_input(Utils.Direction.RIGHT)


func apply_movement() -> Vector2:
	direction = Input.get_axis("move_left", "move_right")
	
	var target_speed = direction * equipament.data.max_speed
	
	if direction != 0.:
		velocity.x = lerp(velocity.x, float(target_speed), equipament.data.acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, equipament.data.friction)
	
	_update_sprite_direction()
	return velocity


func apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = equipament.data.jump_velocity


func force_jump() -> void:
	if not is_on_floor(): return
	velocity.y = equipament.data.jump_velocity
