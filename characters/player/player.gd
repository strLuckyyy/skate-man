class_name Player
extends BaseCharacter

var hud:           CanvasLayer
var race_result:   Result
var score_manager: ScoreManager
var input_buffer:  InputBuffer
var race_position: int:
	set(value):
		race_position = value
		EventBus.race_position_updated.emit(value)

# ---------------------------------------------------------------------------
# Life cycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	super._ready()
	hud           = $HUD
	race_result   = $ResultLayer/Result
	input_buffer  = %InputBuffer
	score_manager = %ScoreManager
	
	var trie_navigator  = $TrieNavigator
	var sequence_signal = trie_navigator.sequence_resolved
	
	score_manager. setup(self)
	trie_navigator.setup(equipment)
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
	
	var cam = %Camera2D
	cam.reparent(get_tree().current_scene)
	
	hud.visible = false
	hud.set_process(false)
	hud.process_mode = Node.PROCESS_MODE_DISABLED
	
	race_result.visible = true
	race_result.set_process(true)
	race_result.process_mode = Node.PROCESS_MODE_ALWAYS
	race_result.result(race_position)
	
	score_manager.end_race()


func _calculate_movement() -> void:
	if Input.is_action_just_pressed("push") and is_on_floor():
		apply_push()
	
	if Input.is_action_just_pressed("jump"):
		apply_jump()
	
	controller.update_moving_state(velocity)


func apply_push(forced := false) -> void:
	super.apply_push(forced)
	velocity = controller.apply_push(velocity, equipment.current_equipment, current_boost_speed, forced)

# ---------------------------------------------------------------------------
# Gameplay callbacks
# ---------------------------------------------------------------------------

func get_caught() -> void:
	super.get_caught()
	state_machine.transition_to(Global.StateID.CAUGHT)
