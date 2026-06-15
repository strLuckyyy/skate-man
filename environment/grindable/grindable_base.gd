class_name GrindableObject
extends Node2D

@onready var path: Path2D = $Path2D
@export var obstacle_data: ObstacleData = null

# Retorna a curva matemática que o player precisa seguir
func get_curve() -> Curve2D:
	return path.curve

# O Path2D calcula curvas em posições locais (0,0). 
# O player vai precisar da posição global do rail para se achar no mundo.
func get_global_start_position() -> Vector2:
	return path.global_position
