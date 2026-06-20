class_name Spawner
extends Node2D


func spawn_character(
	character_scene: PackedScene, equipment: EquipmentData = null) -> BaseCharacter:
	if character_scene == null:
		return

	var character = character_scene.instantiate()

	if equipment != null:
		character.equip(equipment)

	character.global_position = global_position
	get_tree().current_scene.add_child(character)
	return character
