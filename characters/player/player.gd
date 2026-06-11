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
	
	_calculate_movement()
	
	move_and_slide()


func _calculate_movement() -> void:
	if Input.is_action_just_pressed("push"):
		controller.apply_push(velocity, equipment.current_equipment)
	
	if Input.is_action_just_pressed("jump"):
		velocity = controller.apply_jump(velocity, equipment.current_equipment)

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
