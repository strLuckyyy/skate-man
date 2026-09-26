class_name EquipmentManager
extends Node

signal equipment_changed(equipment: EquipmentData, tricks: Array[BaseTrick])

@onready var animated_sprite:   CharacterAnimator = %CharacterAnimator
@export  var default_equipment: EquipmentData
var current_equipment:          EquipmentData
var _current_tricks:            Array[BaseTrick] = []

func get_trick_pool(state: Global.StateID = Global.StateID.NONE) -> Array[TrickData]:
	var pool: Array[TrickData] = []

	for trick: BaseTrick in _current_tricks:
		if state == Global.StateID.NONE:
			pool.append(trick.trick_data)
			continue

		if state in trick.get_state_available():
			pool.append(trick.trick_data)

	return pool


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
	#print(get_tricks())


func get_tricks() -> Array[BaseTrick]:
	return _current_tricks.duplicate()


func _build_tricks() -> Array[BaseTrick]:
	_clear_tricks()
	var tricks: Array[BaseTrick] = []
	
	for trick_data: TrickData in current_equipment.tricks:
		if trick_data == null:
			push_error(
				"Equipment contains a null TrickData. Object: ",
				owner.name
			)
			continue

		var trick := BaseTrick.new()

		trick.trick_data = trick_data
		trick.setup(animated_sprite)

		tricks.append(trick)
	
	# order by priority
	tricks.sort_custom(func(a: BaseTrick, b: BaseTrick) -> bool:
		if not a.trick_data or not b.trick_data:
			return false
		return a.trick_data.priority < b.trick_data.priority
	)
	
	for trick in tricks:
		add_child(trick)
	return tricks


func _clear_tricks() -> void:
	for trick in _current_tricks:
		trick.queue_free()
	_current_tricks.clear()
