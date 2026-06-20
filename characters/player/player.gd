class_name Player
extends BaseCharacter

@onready var hud: CanvasLayer = $HUD
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


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if controller.is_locked:
		move_and_slide()
		return
	
	trick_system.process(
		state_machine.get_current_state_id(),
		can_grind(),
		available_grindable
	)
	
	_calculate_movement()
	state_machine.process_physics(delta)
	
	move_and_slide()


func end_race():
	super.end_race()
	hud.visible = false
	hud.set_process(false)
	hud.process_mode = Node.PROCESS_MODE_DISABLED


func _calculate_movement() -> void:
	if Input.is_action_just_pressed("push") and is_on_floor():
		apply_push()
	
	if Input.is_action_just_pressed("jump"):
		velocity = controller.apply_jump(velocity, equipment.current_equipment)
	
	controller.update_moving_state(velocity)


func apply_push(forced := false) -> void:
	velocity = controller.apply_push(velocity, equipment.current_equipment, current_boost_speed, forced)


# ---------------------------------------------------------------------------
# Gameplay callbacks
# ---------------------------------------------------------------------------

func get_caught() -> void:
	super.get_caught()
	state_machine.transition_to(Global.StateID.CAUGHT)
