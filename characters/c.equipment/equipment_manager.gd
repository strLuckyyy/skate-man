class_name EquipmentManager
extends Node

@export var default_equipment: EquipmentData
var current_equipment: EquipmentData
var _current_tricks: Array[BaseTrick] = []

signal equipment_changed(equipment: EquipmentData, tricks: Array[BaseTrick])


func _ready() -> void:
	await owner.ready
	if current_equipment == null:
		equip(default_equipment)


func equip(equipment: EquipmentData):
	if equipment == null:
		push_error("Trying to equip null equipment")
		return

	current_equipment = equipment
	_current_tricks = _build_tricks()
	emit_signal("equipment_changed", equipment, get_tricks())


func get_tricks() -> Array[BaseTrick]:
	return _current_tricks.duplicate()


func _build_tricks() -> Array[BaseTrick]:
	var result: Array[BaseTrick] = []

	for packed_scene in current_equipment.tricks:
		var trick = packed_scene.instantiate() as BaseTrick
		if trick == null:
			push_error("Trick scene does not extend BaseTrick")
			continue
		result.append(trick)
		print(trick.name)
	return result
