class_name EquipmentData 
extends Resource

@export var tricks:          Array[PackedScene]
@export var max_speed:       float = 1000.
@export var max_boost_speed: float = 3000.

## must be a value between 0.0 and 1.0
@export_range(0.0, 1.0) var acceleration: float = 0.3

## must be a value between 0.0 and 1.0
@export_range(0.0, 1.0) var friction:     float = 0.2

@export var recouver_timeout: float = .8 
@export var speed_modifier:   float = 1.0
@export var jump_modifier:    float = 400.0
@export var anim_set:         StringName
