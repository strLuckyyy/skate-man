class_name RandomizerConfig
extends Resource

@export_group("Pesos Decisão Base")
@export var nothing_weight:    float = 1.0
@export var jump_weight:       float = 1.0
@export var trick_weight:      float = 1.0
@export var difficulty_weight: float = 0.0

@export_group("Penalidades dos Buffers")
@export var action_penalty_weights: Array[float] = []
@export var trick_penalty_weights:  Array[float] = []
