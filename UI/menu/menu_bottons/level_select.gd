class_name LevelSelect
extends VBoxContainer

@export var is_level_select_load: int = 0

@onready var level_sprite:  TextureRect = %LevelSprite
@onready var level_name:    Label       = %LevelName
@onready var map_label:     Label       = %MapLabel
@onready var weather_label: Label       = %WeatherLabel
@onready var score_label:   Label       = %ScoreLabel

@onready var opponent_sprite:  TextureRect = %OpponentSprite
@onready var equipment_sprite: TextureRect = %EquipmentSprite

@onready var opponent_name:    Label              = %OpponentName
@onready var opponent_speed:   TextureProgressBar = %OpponentSpeed
@onready var opponent_boost:   TextureProgressBar = %OpponentBoost
@onready var level_difficulty: TextureProgressBar = %LevelDifficulty

@onready var btn_left:  Button = %LeftButton
@onready var btn_right: Button = %RightButton
@onready var btn_play:  Button = %PlayButton

var level_route: LevelListData
var level_list: Array[LevelData]
var _index: int = 0
var _game_loaded: bool = false
var _current_level_completed: bool = false
var _level_locked: LevelData = preload("res://levels/level_locked.tres")


func _ready() -> void:
	btn_left.pressed.connect(_change_level.bind(-1))
	btn_right.pressed.connect(_change_level.bind(1))
	_show_level(0)
	
	SaveManager.loaded.connect( func(): _game_loaded = true )


func level_select(lvl_select: LevelListData):
	if lvl_select == null:
		level_list = []
	else:
		level_route = lvl_select
		level_list = lvl_select.level_list
	_show_level(_index)


func _change_level(step: int) -> void:
	_show_level(_index + step)


func _show_level(index: int) -> void:
	if level_list.is_empty():
		btn_left.disabled = true
		btn_right.disabled = true
		return
	
	_index = clampi(index, 0, level_list.size() - 1)
	
	var level: LevelData = level_list[_index]
	var score: float = 0.0
	
	if _game_loaded:
		score = SaveManager.get_level_score(str(_index))
		_current_level_completed = SaveManager.get_level_is_completed(str(_index))
	
	_show_info(level, score)
	if level.level_locked:
		_show_info(_level_locked, 0.0)
	
	btn_play.disabled = level.level_locked
	
	_update_buttons()


func _show_info(level_data: LevelData, score: float) -> void:
	level_name.text      = level_data.level_name
	level_sprite.texture = level_data.level_perfil
	map_label.text       = str(LevelData.MapType.find_key(level_data.map_type))
	weather_label.text   = str(LevelData.Weather.find_key(level_data.weather))
	score_label.text     = str(score)

	opponent_sprite.texture  = level_data.opponent_perfil
	equipment_sprite.texture = level_data.equipment_perfil

	opponent_name.text     = level_data.opponent_name
	opponent_speed.value   = level_data.opponent_speed
	opponent_boost.value   = level_data.opponent_boost
	level_difficulty.value = level_data.difficulty


func _update_buttons() -> void:
	btn_left.disabled  = _index <= 0
	btn_right.disabled = _index >= level_list.size() - 1
	
	if btn_left.disabled and btn_left.has_focus():
		btn_right.grab_focus()
	elif btn_right.disabled and btn_right.has_focus():
		btn_left.grab_focus()


func _on_play_button_pressed() -> void:
	GameManager.start_level(level_list[_index], _index, level_route)
