class_name GrindComponent
extends Node

signal grind_finished(reason: String) # reasons: "end_of_rail", "jumped"

var character:     CharacterBody2D
var current_rail:  GrindableObject
var current_curve: Curve2D

var current_offset:  float = 0.0
var grind_direction: float = 1.0
var current_speed:   float = 0.0

var is_grinding: bool = false

func setup(p_character: CharacterBody2D) -> void:
	character = p_character


func start_grind(rail: GrindableObject, entry_velocity: Vector2) -> void:
	is_grinding   = true
	current_rail  = rail
	current_curve = rail.get_curve()
	
	# 1. Descobre onde o player caiu no cano
	var local_pos = character.global_position - current_rail.get_global_start_position()
	current_offset = current_curve.get_closest_offset(local_pos)
	
	# 2. Define a direção baseada na velocidade horizontal de entrada
	grind_direction = 1.0 if entry_velocity.x >= 0 else -1.0
	current_speed = character.velocity.x
	
	# Zera velocidade física para o componente assumir o controle
	character.velocity = Vector2.ZERO

# Chamado dentro do update() do OnGridingState
func process_grind(delta: float) -> void:
	if not current_rail: return
	
	# Avança o offset
	current_offset += (current_speed * grind_direction) * delta
	var total_length = current_curve.get_baked_length()
	
	# Verifica se chegou no fim ou começo do trilho
	if current_offset > total_length or current_offset < 0:
		exit_grind(Global.ReasonToExitGrind.END_OF_RAIL)
		return
	
	if Input.is_action_just_pressed("jump"):
		exit_grind(Global.ReasonToExitGrind.JUMPED)
		return
	
	# Atualiza a posição do CharacterBody2D
	var new_local_pos = current_curve.sample_baked(current_offset)
	character.global_position = current_rail.get_global_start_position() + new_local_pos

func exit_grind(reason: Global.ReasonToExitGrind) -> void:
	is_grinding   = false
	current_rail  = null
	current_curve = null
	var data = {
		"direction": grind_direction,
		"speed":     current_speed
	}
	grind_finished.emit(reason, data)
