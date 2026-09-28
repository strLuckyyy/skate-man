class_name TrickData
extends Resource

@export var priority: int
@export var trick_name: String
@export var sequence: Array[Global.Direction]

@export_category("Availability")
@export var state_available: Array[Global.StateID]
@export var conditional_state_available: Array[Global.StateID]
@export var is_grind_trick: bool = false

@export_category("Execution")
@export var cd: float = 1.0
@export var boost: float = 150
@export var score_bonus: int = 100
@export var animation_name: StringName

@export_category("Hold")
@export var hold_direction: Global.Direction = Global.Direction.NONE