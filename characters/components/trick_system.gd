class_name TrickSystem
extends Node

signal trick_started(trick: BaseTrick)
signal grind_trick_requested(grindable: GrindableObject)

var character:          BaseCharacter
var equipment:          EquipmentData
var animator:           CharacterAnimator
var active_trick:       BaseTrick = null
var is_busy:            bool      = false
var _grind_opportunity: bool      = false
var _current_state:     Global.StateID
var _current_grindable: GrindableObject


func setup(
	char_ref: BaseCharacter,
	equipment_manager: EquipmentManager, 
	character_animator: CharacterAnimator,
	trick_sequence_signal: Signal
) -> void:
	if trick_sequence_signal != null:
		trick_sequence_signal.connect(_on_sequence_resolved)
	
	character = char_ref
	animator  = character_animator
	
	equipment_manager.equipment_changed.  connect(_on_equipment_changed)
	animator.trick_animation_finished.    connect(_on_trick_anim_finished)
	
	character.state_machine.state_changed.connect(_on_state_changed)


func process(
		state_id:          Global.StateID,
		grind_opportunity: bool,
		grindable:         GrindableObject = null
) -> void:
	_current_state      = state_id
	_grind_opportunity  = grind_opportunity
	_current_grindable  = grindable


func try_execute(context: TrickContext, trick: BaseTrick) -> void:
	if is_busy: return
	is_busy      = true
	active_trick = trick
	
	var anim_name = trick.trick_data.animation_name
	animator.play_trick(str("tricks/", anim_name))
	
	EventBus.trick_detected.emit(trick.trick_data)
	trick_started.emit(trick) 
	
	if trick.is_grind_trick and context.get_grind_opportunity():
		grind_trick_requested.emit(_current_grindable)
	
	character.boost_component.add_boost(trick.trick_data.boost)
	trick.execute(context)

# ---------------------------------------------------------------------------
# Private — sequence resolution
# ---------------------------------------------------------------------------

func _on_state_changed(
	_old_state: Global.StateID, new_state: Global.StateID
) -> void:
	if new_state == Global.StateID.TRICK_FAIL and is_busy:
		is_busy = false
		if active_trick != null:
			EventBus.trick_failed.emit(active_trick)
		active_trick = null


func _on_sequence_resolved(
	candidates: Array[BaseTrick], path: Array[Global.Direction]
) -> void:
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
