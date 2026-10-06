class_name Menu
extends Node

#const LEVEL_1: PackedScene = preload("res://levels/level_01/level_01.tscn")

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var start_jump: Button = $CanvasLayer/Control/StartMenuJump
@onready var main_menu: HBoxContainer = $CanvasLayer/Control/MainMenu
@onready var new_game:  HBoxContainer = $CanvasLayer/Control/NewGameMenu

var can_jump_animation: bool = true
var _last_condition: String = ""


func _ready() -> void:
	var main_menu_btn    := $"CanvasLayer/Control/StartMenu/VBoxContainer/Start-MainMenu"
	var new_game_btn     := $"CanvasLayer/Control/MainMenu/VBoxContainer/NewGame"
	var level_select_btn := $CanvasLayer/Control/NewGameMenu/VBoxContainer/LevelSelect
	var tutorial_bnt     := $CanvasLayer/Control/NewGameMenu/VBoxContainer/Tutorial
	var back_menu        := $CanvasLayer/Control/LevelSelect/BottomArea/MarginContainer/HBoxContainer/BackButton
	
	main_menu_btn.pressed.connect(_change_menu_cascate.bind("start_press"))
	new_game_btn.pressed.connect(_change_menu_cascate.bind("new_game"))
	level_select_btn.pressed.connect(_change_menu_cascate.bind("level_select"))
	tutorial_bnt.pressed.connect(_change_menu_cascate.bind("level_select"))
	back_menu.pressed.connect(_change_menu_cascate.bind("ls_back_menu"))


func _jump_start() -> void:
	if !can_jump_animation: return
	animation_tree.set("parameters/conditions/start_menu_in", true)
	can_jump_animation  = false
	start_jump.disabled = true


func _change_menu_cascate(condition_name: String) -> void:
	animation_tree.set("parameters/conditions/" + condition_name, true)
	
	if _last_condition != "":
		animation_tree.set("parameters/conditions/" + _last_condition, false)
	
	_last_condition = condition_name


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name == "start_menu_in": 
		_jump_start()
		return
	
	var condition: String = "parameters/conditions/" + anim_name
	if animation_tree.get(condition) != null:
		animation_tree.set(condition, true)


func _on_start_menu_jump_pressed() -> void:
	_jump_start()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	pass # Replace with function body.
