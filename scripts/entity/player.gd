class_name Player
extends BaseCharacter


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	input_handler()
	move_and_slide()


func input_handler():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func move() -> void:
	direction.x = Input.get_axis("move_left", "move_right")
	
	if direction.x != 0:
		velocity.x = direction.x * MAX_SIMPLE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SIMPLE_SPEED)
