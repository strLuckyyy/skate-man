# LevelManager.gd
class_name LevelManager
extends Node2D

@onready var player_scene:      PackedScene   = preload(
	"res://characters/player/player.tscn")
@onready var default_equipment: EquipmentData = preload(
	"res://characters/equipment/hand_truck/hand_truck.tres")
@onready var result := $CanvasLayer/Result
@onready var countdown := Countdown.new()

@export var spawner:      Spawner
@export var race_manager: RaceManager
@export var canvas:       CanvasLayer

var data:         LevelData
var race_running: bool = false
var can_start_cd: bool = false
var racers:       Array
var cd_label:     Label
var player_score: float = 0.0


func _ready() -> void:
	if GameManager.level_data == null:
		push_error("whitout data")
	data = GameManager.level_data
	
	get_tree().paused = false
	race_manager.race_finished.connect(finish)
	cd_label = race_manager.get_countdown_label()
	
	EventBus.race_ended.connect(
		func(score):
			player_score = score
	)
	
	_spawn()
	
	await get_tree().create_timer(1.0).timeout
	countdown.begin(3.)
	can_start_cd = true


func _process(delta: float) -> void:
	if race_running: return
	cd_label.text = str(int(countdown.get_remaining_time()))
	
	if not can_start_cd: return
	countdown.update(delta)
	
	if countdown.countdown_ended():
		cd_label.text = ""
		race_running  = true
		for i : BaseCharacter in racers: i.start_race()


@warning_ignore("shadowed_variable_base_class")
func finish(position: int):
	var pause_menu = canvas.get_node_or_null("Pause")
	if pause_menu and pause_menu.has_method("set_pause_enabled"):
		pause_menu.call("set_pause_enabled", false)
	
	get_tree().paused = true
	
	var is_completed: bool = true if position == 1 else false
	
	SaveManager.update_level_progress(
		data.id, 
		player_score, 
		is_completed,
	)
	SaveManager.save_game()
	
	result.result(position)
	result.visible = true


func _spawn() -> void:
	var racer: BaseCharacter
	if data.opponent != null: 
		racer = spawner.spawn_character(data.opponent)
		spawner.global_position.x -= 10
		racers.append(racer)
	
	racer = spawner.spawn_character(player_scene)
	racer.equip(default_equipment)
	racers.append(racer)
