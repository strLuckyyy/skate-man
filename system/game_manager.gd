# GameManager.gd
extends Node

## Cenas e recursos globais

func start_level(level_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(level_scene)
