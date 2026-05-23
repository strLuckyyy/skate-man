class_name Player
extends BaseCharacter

var input_buffer: InputBuffer
var state_machine: StateMachine


# ---------------------------------------------------------------------------
# Life cycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	input_buffer  = find_child("InputBuffer")      as InputBuffer
	state_machine = find_child("StateMachine")     as StateMachine
	trick_system  = find_child("TrickSystem")      as TrickSystem
	equipment     = find_child("EquipmentManager") as EquipmentManager
	controller    = find_child("Controller")       as PlayerController
	foot_ref      = find_child("FootPosition")     as CollisionShape2D

	GameManager.player = self
	state_machine.setup(self)

	# --- EventBus connections ---
	EventBus.grind_started.connect(_is_on_grinding)
	EventBus.player_lock_requested.connect(on_lock_character)
	EventBus.player_unlock_requested.connect(on_unlock_character)
	EventBus.platform_lock_character.connect(on_lock_character)
	EventBus.platform_unlock_character.connect(on_unlock_character)


func _physics_process(delta: float) -> void:
	print(velocity.x)
	if is_locked:
		move_and_slide()
		return
	
	_apply_gravity(delta)
	_update_moving_state()
	
	trick_system.process(
		state_machine.get_current_state_id(),
		can_grind,
		_current_grindable
	)
	
	_calculate_velocity()
	move_and_slide()
	
	if _is_grinding and _current_grindable != null:
		global_position = _current_grindable.get_grind_position()
		velocity        = Vector2.ZERO


# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func _apply_movement() -> void:
	if not can_move:
		velocity.x = move_toward(velocity.x, 0.0, equipment.current_equipment.friction)
		return

	if controller.get_auto_move_active():
		velocity = controller.apply_auto_movement(velocity, equipment.current_equipment, current_boost_speed)
	else:
		velocity = controller.apply_movement(velocity, equipment.current_equipment, current_boost_speed)


func _apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and can_jump and _jumped == 0:
		velocity.y  = controller.apply_jump(equipment.current_equipment)
		_jumped    += 1
		_is_jumping = true


# ---------------------------------------------------------------------------
# Lock / Unlock
# ---------------------------------------------------------------------------

func on_lock_character(_body: BaseCharacter) -> void:
	if _body != self:
		return
	is_locked = true
	velocity  = Vector2.ZERO
	controller.clear_auto_move()


func on_unlock_character() -> void:
	is_locked = false

# ---------------------------------------------------------------------------
# Gameplay callbacks
# ---------------------------------------------------------------------------

func player_caught() -> void:
	state_machine.transition_to(Global.StateID.CAUGHT)


func _is_on_grinding(grindable: ObjectGrindable) -> void:
	var state := state_machine.get_current_state_id()
	
	if _jumped == 0: return
	if grindable == null: return
	if state != Global.StateID.ON_AIR and state != Global.StateID.ON_FALLING: return
	if not grindable.is_foot_aligned(get_foot_position()): return
	if not grindable.can_accept_speed(abs(velocity.x)): return
	
	_current_grindable = grindable
	start_grind()
