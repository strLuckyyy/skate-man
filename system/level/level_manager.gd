# LevelManager.gd
class_name LevelManager
extends Node2D

@onready var player_scene:      PackedScene   = preload(
	"res://characters/player/player.tscn")
@onready var default_equipment: EquipmentData = preload(
	"res://characters/equipment/hand_truck/hand_truck.tres")
@onready var countdown := Countdown.new()

@export var spawner:      Spawner
@export var race_manager: RaceManager
 
var level_id:     int
var data:         LevelData
var race_running: bool = false
var can_start_cd: bool = false
var racers:       Array[BaseCharacter]
var cd_label:     Label
var player_score: float = 0.0


func _ready() -> void:
	if GameManager.level_data == null:
		GameManager.testing_mode()
	data = GameManager.level_data
	
	get_tree().paused = false
	EventBus.race_finished.connect(finish)
	cd_label = race_manager.get_countdown_label()
	
	EventBus.race_ended.connect( 
		func(base_character, score): 
			if base_character == Player:
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
	var is_completed: bool = true if position == 1 else false
	
	SaveManager.update_level_progress(
		GameManager.current_level_id, 
		player_score, 
		is_completed,
	)
	SaveManager.save_game()
	
	race_running = false


func _spawn() -> void:
	var racer: BaseCharacter
	if data.opponent != null: 
		racer = spawner.spawn_character(data.opponent, race_manager)
		spawner.global_position.x -= 10
		racers.append(racer)
	
	racer = spawner.spawn_character(player_scene, race_manager, default_equipment)
	racers.append(racer)
	EventBus.characters_spawned.emit(racers)
