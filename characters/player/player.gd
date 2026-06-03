class_name Player
extends BaseCharacter

var input_buffer:  InputBuffer

# ---------------------------------------------------------------------------
# Life cycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	if %StateManager is not StateMachine: 
		push_error("In Player node, State Manager must be State Machine.")
	state_manager = %StateManager as StateMachine
	input_buffer  = %InputBuffer
	
	var trie_navigator  = $TrieNavigator
	var sequence_signal = trie_navigator.sequence_resolved
	
	trie_navigator.setup(input_buffer, equipment)
	trick_system.  setup(self, equipment, character_animator, sequence_signal)
	state_manager. setup(self)
	state_manager. setup(self)
	
	GameManager.player = self
	
	# --- Signals connections ---
	trick_system.grind_trick_requested.connect(_on_grind_trick_requested)
	EventBus.grind_started.            connect(_on_grind_trick_requested)
	EventBus.player_lock_requested.    connect(on_lock_character)
	EventBus.player_unlock_requested.  connect(on_unlock_character)
	EventBus.platform_lock_character.  connect(on_lock_character)
	EventBus.platform_unlock_character.connect(on_unlock_character)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if controller.is_locked:
		move_and_slide()
		return
	
	controller.update_moving_state(velocity)
	
	trick_system.process(
		state_manager.get_current_state_id(),
		can_grind(),
		available_grindable
	)
	
	_calculate_velocity()
	move_and_slide()

# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func _calculate_velocity() -> void:
	_apply_movement()
	_apply_jump()


func _apply_movement() -> void:
	if controller.get_auto_move_active():
		velocity = controller.apply_auto_movement(velocity, equipment.current_equipment, current_boost_speed)
	else:
		velocity = controller.apply_movement(velocity, equipment.current_equipment, current_boost_speed)


func _apply_jump() -> void:
	velocity = controller.apply_jump(velocity, equipment.current_equipment)


func _on_grind_trick_requested(grindable: GrindableObject) -> void:
	var state := state_manager.get_current_state_id()
	
	if controller.jumped == 0: return
	if grindable == null: return
	if state != Global.StateID.ON_AIR and state != Global.StateID.ON_FALLING: return
	
	state_manager.transition_to(Global.StateID.ON_GRIDING, grindable)

# ---------------------------------------------------------------------------
# Lock / Unlock
# ---------------------------------------------------------------------------

func on_lock_character(_body: BaseCharacter) -> void:
	if _body != self:
		return
	controller.is_locked = true
	velocity  = Vector2.ZERO
	controller.clear_auto_move()


func on_unlock_character() -> void:
	controller.is_locked = false

# ---------------------------------------------------------------------------
# Gameplay callbacks
# ---------------------------------------------------------------------------

func player_caught() -> void:
	state_manager.transition_to(Global.StateID.CAUGHT)
