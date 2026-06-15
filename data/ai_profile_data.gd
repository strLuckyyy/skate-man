class_name AIProfileData
extends Resource

@export_range(0.0, 1.0) var perfection_chance: float = 0.8 # 80% de chance de acertar a manobra
@export_range(0.0, 1.0) var optimal_path_chance: float = 0.7 # 70% de chance de escolher a rota mais rápida (grind)
@export var reaction_delay: float = 0.2 # Tempo de atraso para pular/fazer manobra
@export var aggression: float = 1.0 # O quão frequente ela tenta manobras no chão
