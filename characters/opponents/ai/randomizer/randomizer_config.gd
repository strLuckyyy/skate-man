class_name RandomizerConfig
extends RefCounted

# Pesos de decisão base
var nothing_weight:    float = 5.0
var jump_weight:       float = 5.0
var trick_weight:      float = 5.0
var difficulty_weight: float = 6.0

# Penalidades para o buffer de ação (tamanho 8)
var action_penalty_weights: Array[float] = [
	80.0, 70.0, 60.0, 45.0, 35.0, 20.0, 10.0, 0.0
]

# Penalidades para o buffer de manobra (tamanho 3)
var trick_penalty_weights: Array[float] = [
	60.0, 25.0, 0.0
]
