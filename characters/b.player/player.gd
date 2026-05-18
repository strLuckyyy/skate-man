class_name Player
extends CharacterBody2D

@onready var input_buffer: InputBuffer = $InputBuffer
@onready var state_machine: StateMachine = $StateMachine
@onready var trick_system: TrickSystem = $TrickSystem
@onready var equipment: EquipmentManager = $EquipmentManager
@onready var controller: PlayerController = $Controller

# --- Blocking State ---
## When true, all the controllers (input and automatic) is disabled.
## The extern node set the pos by global_position.
var is_locked: bool = false

# --- Animation flags ---
var is_waiting: bool = false
var is_caught: bool = false

# --- Gameplay flags ---
var can_jump: bool = true
var can_grind: bool = false
var can_move: bool = true

var _is_jumping: bool = false
var _jumped: int = 0
var _is_moving: bool = false

var _is_grinding: bool = false

# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------


func is_jumping() -> bool:
	return _is_jumping


func is_grinding() -> bool:
	return _is_grinding


func is_moving() -> bool:
	return _is_moving


func reset_jump() -> void:
	_jumped = 0

# ---------------------------------------------------------------------------
# Life cicle
# ---------------------------------------------------------------------------


func _ready() -> void:
	GameManager.player = self
	state_machine.setup(self)
	equipment.equipment_changed.connect(trick_system.on_equipment_changed)

	#auto movement
	#controller.set_auto_move_right(equipment.current_equipment.max_speed)


func _physics_process(delta: float) -> void:
	if is_locked:
		move_and_slide()
		return

	_apply_gravity(delta)
	_update_moving_state()

	trick_system.process(input_buffer, can_grind, state_machine.get_current_state_id())

	_calculate_velocity()
	move_and_slide()

	if abs(velocity.x) > 1.:
		_is_moving = true
	else:
		_is_moving = false


# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------


func _calculate_velocity() -> void:
	_apply_movement()
	_apply_jump()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		_is_jumping = false


func _update_moving_state() -> void:
	_is_moving = abs(velocity.x) > 1.0


func _apply_movement() -> void:
	if not can_move:
		velocity.x = move_toward(velocity.x, 0.0, equipment.current_equipment.friction)
		return

	if controller.get_auto_move_active():
		velocity = controller.apply_auto_movement(equipment.current_equipment, velocity)
	else:
		velocity = controller.apply_movement(velocity, equipment.current_equipment)


func _apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and can_jump and _jumped == 0:
		velocity.y = controller.apply_jump(equipment.current_equipment)
		_jumped += 1
		_is_jumping = true


func on_lock_player(_body: CharacterBody2D) -> void:
	if _body != self:
		return
	is_locked = true
	velocity = Vector2.ZERO
	controller.clear_auto_move()


func on_unlock_player() -> void:
	is_locked = false
	#controller.set_auto_move_right(equipment.current_equipment.max_speed)

# ---------------------------------------------------------------------------
# Callbacks de gameplay (mantidos do código original)
# ---------------------------------------------------------------------------

func player_caught() -> void:
	state_machine.transition_to(Global.StateID.CAUGHT)


func on_grinding_area(_can_grind: bool, _area: GrindArea) -> void:
	can_grind = _can_grind
