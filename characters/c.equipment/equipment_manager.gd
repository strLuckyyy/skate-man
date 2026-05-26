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
		push_error("Trying to equip null equipment")
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
			push_error("Trick scene does not extend BaseTrick")
			continue
		scenes.append(trick)
	
	# Order by priority
	var i = 0
	var result: Array[BaseTrick] = []
	while i < scenes.size():
		for trick in scenes:
			if trick.trick_data.priority == i:
				add_child(trick)
				result.append(trick)
		i += 1
	return result


func _clear_tricks() -> void:
	for trick in _current_tricks:
		trick.queue_free()
	_current_tricks.clear()
