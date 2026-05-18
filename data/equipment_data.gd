class_name EquipmentData 
extends Resource

@export var tricks: Array[PackedScene]
@export var max_speed: float = 2000.

## must be a value between 0.0 and 1.0
@export_range(0.0, 1.0) var acceleration: float = 0.3

## must be a value between 0.0 and 1.0
@export_range(0.0, 1.0) var friction: float = 0.2

@export var speed_modifier: float = 1.0
@export var jump_modifier: float = 400.0

@export var anim_set: StringName
