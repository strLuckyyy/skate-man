class_name Player
extends BaseCharacter

var input_buffer:  InputBuffer

# ---------------------------------------------------------------------------
# Life cycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	input_buffer = %InputBuffer
	
	var trie_navigator  = $TrieNavigator
	var sequence_signal = trie_navigator.sequence_resolved
	
	trie_navigator.setup(input_buffer, equipment)
	trick_system.  setup(self, equipment, character_animator, sequence_signal)
	
	GameManager.player = self
	
	# --- Signals connections ---
	trick_system.grind_trick_requested.connect(_on_grind_trick_requested)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if controller.is_locked:
		move_and_slide()
		return
	
	controller.update_moving_state(velocity)
	
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
	var state := state_machine.get_current_state_id()
	
	if controller.jumped == 0: return
	if grindable == null: return
	if state != Global.StateID.ON_AIR and state != Global.StateID.ON_FALLING: return
	
	state_machine.transition_to(Global.StateID.ON_GRIDING, grindable)

# ---------------------------------------------------------------------------
# Lock / Unlock
# ---------------------------------------------------------------------------

func on_lock_character(_body: BaseCharacter) -> void:
	if _body != self: return
	controller.is_locked = true
	velocity  = Vector2.ZERO
	controller.clear_auto_move()


func on_unlock_character() -> void:
	controller.is_locked = false

# ---------------------------------------------------------------------------
# Gameplay callbacks
# ---------------------------------------------------------------------------

func get_caught() -> void:
	super.get_caught()
	state_machine.transition_to(Global.StateID.CAUGHT)
