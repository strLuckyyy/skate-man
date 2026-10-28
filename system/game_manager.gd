# GameManager.gd
extends Node


@onready var main_menu := preload("res://UI/menu/menu.tscn")

var current_level_id: int
var level_data: LevelData
var level_testing_data: LevelData = preload("res://levels/tutorial/tutorial_1/1_push_and_jump_tt.tres")

var current_level_route: LevelListData


func get_has_next_level() -> bool:
	var nxt_id = current_level_id + 1
	return current_level_route.level_list.size() > nxt_id


func testing_mode() -> void:
	level_data = level_testing_data
	print("TESTING MODE: ON")


func load_main_menu() -> void:
	SaveManager.save_game()
	get_tree().change_scene_to_packed(main_menu)


func load_next_level() -> void:
	if get_has_next_level():
		SaveManager.save_game()
		var next_id    := current_level_id + 1
		var next_level := current_level_route.level_list[next_id]
		start_level(next_level, next_id, current_level_route)


func start_level(data: LevelData, level_id: int, level_route: LevelListData) -> void:
	if data == null or data.level_scene == null:
		push_error("start_level: LevelData ou level_scene inválido")
		return
	level_data          = data
	current_level_id    = level_id
	current_level_route = level_route
	
	get_tree().change_scene_to_packed(level_data.level_scene)
