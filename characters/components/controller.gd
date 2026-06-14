class_name Controller
extends Node

var is_locked:     bool  = false
var is_trick_fail: bool  = false
var can_jump:      bool  = true
var can_move:      bool  = true
var is_jumping:    bool  = false
var is_moving:     bool  = false
var jumped:        int   = 0
var direction:     float = 1.0 # 1.0 direita; -1.0 esquerda

var _push_cooldown:  float = 0.4
var _last_push_time: float = 0.0

func is_jumped()    -> bool: return jumped > 0
func reset_jumped() -> void: jumped = 0


func set_permissions(can_move_val: bool = true, can_jump_val: bool = true) -> void:
	self.can_move = can_move_val; self.can_jump = can_jump_val


func change_direction(dir: Global.Direction) -> void:
	if dir == Global.Direction.RIGHT: direction = 1.0
	elif dir == Global.Direction.LEFT: direction = -1.0


func update_moving_state(velocity: Vector2) -> void:
	is_moving = abs(velocity.x) > 5.0 


func apply_push(velocity: Vector2, equipment: EquipmentData, current_boost: float = 0.0) -> Vector2:
	if not can_move: return velocity
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_push_time < _push_cooldown:
		return velocity
	
	_last_push_time = current_time
	
	var burst_force = 400.0 + (current_boost * 0.5) 
	velocity.x += burst_force * direction
	
	var cap = clamp(equipment.max_speed + current_boost, equipment.max_speed, equipment.max_boost_speed)
	velocity.x = clamp(velocity.x, -cap, cap)
	
	return velocity


func apply_momentum(
	delta:         float,
	velocity:      Vector2, 
	is_on_floor:   bool, 
	floor_normal:  Vector2,
	equipment:     EquipmentData, 
	current_boost: float = 0.0) -> Vector2:
	if not can_move: return velocity
	
	if is_on_floor and floor_normal != Vector2.UP:
		var slope_gravity = 1500.0
		velocity.x += floor_normal.x * slope_gravity * delta
	
	var base_friction  = equipment.friction if is_on_floor else (equipment.friction * 0.1)
	var boost_ratio    = clamp(current_boost / equipment.max_boost_speed, 0.0, 0.8)
	var final_friction = base_friction * (1.0 - boost_ratio)
	var friction_force = final_friction * 1000.0 
	
	velocity.x = move_toward(velocity.x, 0.0, friction_force * delta)
	
	if abs(velocity.x) < 5.0 and floor_normal == Vector2.UP:
		velocity.x = 0.0
	
	return velocity


func apply_jump(velocity: Vector2, equipment_data: EquipmentData) -> Vector2:
	if can_jump and jumped == 0:
		jumped    += 1
		is_jumping = true
		velocity.y = -equipment_data.jump_modifier
	return velocity
