# GameManager.gd
extends Node


@onready var main_menu := preload("res://UI/menu/menu.tscn")

var current_level_id: int
var level_data: LevelData
var level_testing_data: LevelData = preload("res://levels/tutorial/tutorial_1/1_push_and_jump_tt.tres")


func testing_mode() -> void:
	level_data = level_testing_data
	print("TESTING MODE: ON")


func load_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)


func start_level(data: LevelData, level_id: int) -> void:
	if data == null or data.level_scene == null:
		push_error("start_level: LevelData ou level_scene inválido")
		return
	level_data       = data
	current_level_id = level_id
	
	get_tree().change_scene_to_packed(level_data.level_scene)
