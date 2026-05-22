class_name TrickData
extends Resource

@export var priority: int
@export var trick_name: String
@export var sequence: Array[Global.Direction]
@export var state_available: Array[Global.StateID]
@export var conditional_state_available: Array[Global.StateID]
@export var cd: float = 1.0
@export var boost: float = 1.5
@export var score_bonus: int = 100
@export var anim_id: StringName
