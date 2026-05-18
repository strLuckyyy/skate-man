extends Node


var player: Player
var hand_truck: EquipmentData = preload("res://characters/c.equipment/hand_truck/hand_truck_data.tres")


func _ready() -> void:
	if player:
		player.equipment.equip(hand_truck)
