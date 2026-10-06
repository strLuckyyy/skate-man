class_name TrickSystem
extends Node

signal trick_started(trick: BaseTrick)
signal grind_trick_requested(grindable: GrindableObject)

var character:             BaseCharacter
var equipment:             EquipmentData
var animator:              CharacterAnimator
var active_trick:          BaseTrick = null
var is_busy:               bool      = false

var _grind_opportunity:    bool = false
var _current_state:        Global.StateID
var _current_grindable:    GrindableObject
var _held_trick_direction: Global.Direction = Global.Direction.NONE


func get_is_doing_trick() -> bool:
	if active_trick == null or animator == null:
		return false
	
	if animator.is_loop_animation(): return false
	return is_busy


func setup(
	char_ref:              BaseCharacter,
	equipment_manager:     EquipmentManager, 
	character_animator:    CharacterAnimator,
	trick_sequence_signal: Signal
) -> void:
	if trick_sequence_signal != null:
		trick_sequence_signal.connect(_on_sequence_resolved)

	EventBus.direction_released.connect(_on_direction_released)

	character = char_ref
	animator  = character_animator
	
	equipment_manager.equipment_changed.connect(_on_equipment_changed)
	animator.animation_tree.animation_finished.connect(_on_trick_anim_finished)
	character.state_machine.state_changed.connect(_on_state_changed)


func process(
		state_id:          Global.StateID,
		grind_opportunity: bool,
		grindable:         GrindableObject = null
) -> void:
	if state_id != _current_state:
		_current_state = state_id
	if grind_opportunity != _grind_opportunity: 
		_grind_opportunity = grind_opportunity
	if grindable != _current_grindable:
		_current_grindable  = grindable


func try_execute(context: TrickContext, trick: BaseTrick) -> void:
	if get_is_doing_trick():           
		print("is doing a trick?")
		return
	if character.controller.is_locked: return
	
	if trick.is_grind_trick and context.get_grind_opportunity():
		grind_trick_requested.emit(_current_grindable)
		if character.state_machine.get_current_state_id() != Global.StateID.ON_GRIDING:
			return
	
	is_busy               = true
	active_trick          = trick
	_held_trick_direction = trick.trick_data.hold_direction
	
	EventBus.trick_detected.emit(trick)
	trick_started.emit(trick)
	
	character.boost_component.add_boost(trick.trick_data.boost)
	trick.execute(context)
	
	animator.play_trick(trick.anim_name, trick.trick_data.is_compose)

# ---------------------------------------------------------------------------
# Private — sequence resolution
# ---------------------------------------------------------------------------

func _on_state_changed(
	_old_state: Global.StateID, new_state: Global.StateID
) -> void:
	if new_state == Global.StateID.TRICK_FAIL:
		if is_busy and active_trick != null: 
			EventBus.trick_failed.emit(active_trick)
	is_busy      = false
	active_trick = null


func _on_sequence_resolved(
	candidates: Array[BaseTrick], path: Array[Global.Direction]
) -> void:
	print("seq=", path, " state=", Global.StateID.find_key(_current_state),
	" busy=", is_busy, " doing a trick=", get_is_doing_trick(), " grind_opp=", _grind_opportunity,
	" candidatos=", candidates.map(func(t): return t.trick_data.trick_name))
	
	var context := TrickContext.new()
	context.build_context(_current_state, _grind_opportunity, path)
	
	if _grind_opportunity and _is_airborne():
		for trick in candidates:
			if trick.is_grind_trick and trick.can_execute(context):
				try_execute(context, trick)
				return
	
	for trick in candidates:
		if not trick.is_grind_trick and trick.can_execute(context):
			try_execute(context, trick)
			return


func _on_direction_released(direction: Global.Direction) -> void:
	if active_trick == null:
		return

	if direction != _held_trick_direction:
		return

	animator.finish_trick()


func _is_airborne() -> bool:
	return _current_state == Global.StateID.ON_AIR \
		or _current_state == Global.StateID.ON_FALLING


func _on_equipment_changed(
	new_equipment: EquipmentData, _new_tricks: Array[BaseTrick]
) -> void:
	equipment = new_equipment


func _on_trick_anim_finished() -> void:
	is_busy      = false
	active_trick = null
	_held_trick_direction = Global.Direction.NONE
