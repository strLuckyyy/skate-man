class_name TrickSystem
extends Node

var equipment: EquipmentData
var _tricks: Array[BaseTrick]


func get_tricks() -> Array[BaseTrick]:
	return _tricks.duplicate()


func try_execute(context: TrickContext, trick: BaseTrick):
	if context == null or trick == null:
		push_error("Not passing right parameters.")
		return
	if trick.can_execute(context):
		trick.execute(context)


func process(buffer: InputBuffer, grind_opportunity: bool, state_id: Global.StateID) -> void:
	var input_buffer = buffer.get_input_buffer()
	var trick = _find_matching_trick(input_buffer)
	if trick == null:
		return
	
	var context = TrickContext.new()
	context.build_context(state_id, grind_opportunity, input_buffer)
	
	if not trick.can_execute(context):
		return
	
	context.build_context(state_id, grind_opportunity, buffer.consume_buffer())
	trick.execute(context)


func _find_matching_trick(buffer) -> BaseTrick:
	for trick in _tricks:
		if trick.match_input(buffer):
			return trick
	return null


func on_equipment_changed(new_equipment: EquipmentData, new_tricks: Array[BaseTrick]) -> void:
	equipment = new_equipment
	_tricks = new_tricks
