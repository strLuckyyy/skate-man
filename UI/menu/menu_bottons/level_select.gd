extends VBoxContainer

@export var level_list: Array[LevelData]

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

var _index: int = 0


func _ready() -> void:
	btn_left.pressed.connect(_change_level.bind(-1))
	btn_right.pressed.connect(_change_level.bind(1))
	_show_level(0)


func _change_level(step: int) -> void:
	_show_level(_index + step)


func _show_level(index: int) -> void:
	if level_list.is_empty():
		btn_left.disabled = true
		btn_right.disabled = true
		return
	
	_index = clampi(index, 0, level_list.size() - 1)
	var level: LevelData = level_list[_index]
	
	level_name.text      = level.level_name
	level_sprite.texture = level.level_perfil
	map_label.text       = str(LevelData.MapType.find_key(level.map_type))
	weather_label.text   = str(LevelData.Weather.find_key(level.weather))
	score_label.text     = str(100.00)
	
	opponent_sprite.texture  = level.opponent_perfil
	equipment_sprite.texture = level.equipment_perfil
	
	opponent_name.text     = level.opponent_name
	opponent_speed.value   = level.opponent_speed
	opponent_boost.value   = level.opponent_boost
	level_difficulty.value = level.difficulty
	
	_update_buttons()


func _update_buttons() -> void:
	btn_left.disabled  = _index <= 0
	btn_right.disabled = _index >= level_list.size() - 1

	if btn_left.disabled and btn_left.has_focus():
		btn_right.grab_focus()
	elif btn_right.disabled and btn_right.has_focus():
		btn_left.grab_focus()


func _on_play_button_pressed() -> void:
	GameManager.start_level(level_list[_index])
