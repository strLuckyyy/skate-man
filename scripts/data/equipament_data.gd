class_name EquipamentData
extends Resource

@export_group("Speed")
@export var max_speed: float          = 600.
@export var acceleration: float       = .08
@export var friction: float           = .02

@export_group("Boost")
@export var max_speed_boost: float    = 1200.
@export var boost_amount: int         = 0
@export var boost_time: float         = 1.5
@export var boost_acceleration: float = .5
@export var boost_friction: float     = .25

@export_group("Jump")
@export var jump_velocity: float         = -450.
