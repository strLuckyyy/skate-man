# GameManager.gd
extends Node

## Cenas e recursos globais
var player_scene: PackedScene = preload("res://characters/player/player.tscn")
var default_equipment: EquipmentData = preload(
	"res://characters/equipment/hand_truck/hand_truck_data.tres")


func start_level(level_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(level_scene)
