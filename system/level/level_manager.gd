# LevelManager.gd
class_name LevelManager
extends Node2D


#signal race_started(racers: Array)
@onready var result: PackedScene = preload("res://UI/result.tscn")
@onready var countdown := Countdown.new()
@onready var cd_label = %Label

@export var data:         LevelData
@export var spawner:      Spawner
@export var race_manager: RaceManager
@export var canvas:       CanvasLayer

var result_inst:         Control
var race_running:        bool = false
var can_start_cd:        bool = false
var racers:              Array


func _ready() -> void:
	#GameManager.level_loaded.connect(_on_level_data_received)
	race_manager.race_finished.connect(finish)
	get_tree().paused = false
	
	var racer: BaseCharacter
	
	for op in data.opponents:
		racer = spawner.spawn_character(op)
		spawner.global_position.x -= 10
		racers.append(racer)
	racer = spawner.spawn_character(GameManager.player_scene)
	racer.equip(GameManager.default_equipment)
	racers.append(racer)
	
	await get_tree().create_timer(1.0).timeout
	countdown.begin(3.)
	can_start_cd = true


func _process(delta: float) -> void:
	cd_label.text = str(int(countdown.get_remaining_time()))
	
	if not can_start_cd: return
	countdown.update(delta)
	
	if countdown.countdown_ended():
		cd_label.text = ""
		race_running = true
		for i : BaseCharacter in racers: i.start_race()


@warning_ignore("shadowed_variable_base_class")
func finish(position: int):
	if result_inst:
		return

	var pause_menu = canvas.get_node_or_null("Pause")
	if pause_menu and pause_menu.has_method("set_pause_enabled"):
		pause_menu.call("set_pause_enabled", false)

	result_inst = result.instantiate() as Result
	canvas.add_child(result_inst)
	result_inst.result(position)
	result_inst.visible = true
	get_tree().paused = true
