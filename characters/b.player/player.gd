class_name Player
extends BaseCharacter

var input_buffer: InputBuffer
var state_machine: StateMachine

# ---------------------------------------------------------------------------
# Life cycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	input_buffer    = %InputBuffer
	state_machine   = %StateMachine
	trick_system    = %TrickSystem
	equipment       = %EquipmentManager
	controller      = %Controller
	grind_component = %GrindComponent
	
	if state_machine:
		state_machine.setup(self)
	if grind_component:
		grind_component.setup(self)
	
	GameManager.player = self
	
	# --- EventBus connections ---
	EventBus.grind_started.connect(_on_grind_trick_requested)
	EventBus.player_lock_requested.connect(on_lock_character)
	EventBus.player_unlock_requested.connect(on_unlock_character)
	EventBus.platform_lock_character.connect(on_lock_character)
	EventBus.platform_unlock_character.connect(on_unlock_character)


func _physics_process(delta: float) -> void:
	if is_locked:
		move_and_slide()
		return
	
	_apply_gravity(delta)
	_update_moving_state()
	
	if not can_move: return
	
	trick_system.process(
		state_machine.get_current_state_id(),
		can_grind(),
		available_grindable
	)
	
	_calculate_velocity()
	move_and_slide()

# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func _apply_movement() -> void:
	if controller.get_auto_move_active():
		velocity = controller.apply_auto_movement(velocity, equipment.current_equipment, current_boost_speed)
	else:
		velocity = controller.apply_movement(velocity, equipment.current_equipment, current_boost_speed)


func _apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and can_jump and _jumped == 0:
		velocity.y  = controller.apply_jump(equipment.current_equipment)
		_jumped    += 1
		_is_jumping = true


func _on_grind_trick_requested(grindable: GrindableObject) -> void:
	var state := state_machine.get_current_state_id()
	
	if _jumped == 0: return
	if grindable == null: return
	if state != Global.StateID.ON_AIR and state != Global.StateID.ON_FALLING: return
	
	state_machine.transition_to(Global.StateID.ON_GRIDING, grindable)


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
