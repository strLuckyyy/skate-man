class_name TrickSystem
extends Node

signal trick_started(trick: BaseTrick)
signal grind_trick_requested(grindable: GrindableObject)

@export var character:  BaseCharacter
var equipment:          EquipmentData
var _current_state:     Global.StateID
var _grind_opportunity: bool
var _current_grindable: GrindableObject


func setup(trie: TrieNavigator, equipment_manager: EquipmentManager) -> void:
	trie.sequence_resolved.connect(_on_sequence_resolved)
	equipment_manager.equipment_changed.connect(_on_equipment_changed)


func process(
		state_id:          Global.StateID,
		grind_opportunity: bool,
		grindable:         GrindableObject = null
) -> void:
	_current_state      = state_id
	_grind_opportunity  = grind_opportunity
	_current_grindable  = grindable


func try_execute(context: TrickContext, trick: BaseTrick) -> void:
	EventBus.trick_detected.emit(trick.trick_data.trick_name if trick.trick_data else "Unknown")
	trick_started.emit(trick) 
	
	if trick.is_grind_trick and context.get_grind_opportunity():
		grind_trick_requested.emit(_current_grindable)
	
	character.boost_component.add_boost(trick.trick_data.boost)
	trick.execute(context)

# ---------------------------------------------------------------------------
# Private — sequence resolution
# ---------------------------------------------------------------------------

func _on_sequence_resolved(candidates: Array[BaseTrick], path: Array[Global.Direction]) -> void:
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


func _on_equipment_changed(new_equipment: EquipmentData, _new_tricks: Array[BaseTrick]) -> void:
	equipment = new_equipment
