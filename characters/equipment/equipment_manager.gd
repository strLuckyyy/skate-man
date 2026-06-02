class_name EquipmentManager
extends Node

signal equipment_changed(equipment: EquipmentData, tricks: Array[BaseTrick])

@export var default_equipment: EquipmentData
var current_equipment:         EquipmentData
var _current_tricks:           Array[BaseTrick] = []


func _ready() -> void:
	await owner.ready
	if current_equipment == null:
		equip(default_equipment)


func equip(equipment: EquipmentData):
	if equipment == null:
		push_error("Trying to equip null equipment. Object: ", owner.name)
		return

	current_equipment = equipment
	_current_tricks   = _build_tricks()
	equipment_changed.emit(equipment, get_tricks())


func get_tricks() -> Array[BaseTrick]:
	return _current_tricks.duplicate()


func _build_tricks() -> Array[BaseTrick]:
	_clear_tricks()
	var scenes: Array[BaseTrick] = []
	
	for packed_scene in current_equipment.tricks:
		var trick = packed_scene.instantiate() as BaseTrick
		if trick == null:
			push_error("Trick scene does not extend BaseTrick. Object: ", owner.name)
			continue
		scenes.append(trick)
	
	# order by priority
	scenes.sort_custom(func(a: BaseTrick, b: BaseTrick) -> bool:
		if not a.trick_data or not b.trick_data:
			return false
		return a.trick_data.priority < b.trick_data.priority
	)
	
	for trick in scenes:
		add_child(trick)
	return scenes


func _clear_tricks() -> void:
	for trick in _current_tricks:
		trick.queue_free()
	_current_tricks.clear()
