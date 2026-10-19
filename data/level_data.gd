class_name LevelData 
extends Resource

enum Weather { Day, Night, Rain, Fog }
enum MapType { Urban, Subway, Parking }

@export_category("Level Info")
@export var level_scene: PackedScene
@export var level_name: StringName
@export var level_perfil: Texture2D
@export var map_type: MapType
@export var weather:  Weather

@export_category("Opponent Info")
@export var opponent: PackedScene
@export var opponent_name: StringName
@export var opponent_speed: float
@export var opponent_boost: float
@export var opponent_perfil: Texture2D
@export var equipment_perfil: Texture2D
@export_range(1, 100) var difficulty: float
