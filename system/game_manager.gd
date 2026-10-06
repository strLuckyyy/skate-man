# GameManager.gd
extends Node


@onready var main_menu := preload("res://UI/menu/menu.tscn")

var level_data: LevelData

func load_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)


func start_level(data: LevelData) -> void:
	if data == null or data.level_scene == null:
		push_error("start_level: LevelData ou level_scene inválido")
		return
	level_data = data
	
	get_tree().change_scene_to_packed(level_data.level_scene)
