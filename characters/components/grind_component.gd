class_name GrindComponent
extends Node

signal grind_finished(reason: Global.ReasonToExitGrind, data: Dictionary)

var character:     BaseCharacter
var controller:    Controller
var current_rail:  GrindableObject
var current_curve: Curve2D

var current_offset:  float = 0.0
var grind_direction: float = 1.0
var current_speed:   float = 0.0

var is_grinding: bool = false

func setup(p_character: CharacterBody2D) -> void:
	character  = p_character
	controller = character.controller


func start_grind(rail: GrindableObject, entry_velocity: Vector2) -> void:
	if entry_velocity.x < 300.: 
		exit_grind(Global.ReasonToExitGrind.JUMPED)
		return
	is_grinding   = true
	current_rail  = rail
	current_curve = rail.get_curve()
	
	var local_pos = character.global_position - current_rail.get_global_start_position()
	current_offset = current_curve.get_closest_offset(local_pos)
	
	grind_direction = 1.0 if entry_velocity.x >= 0 else -1.0
	current_speed = character.velocity.x + character.current_boost_speed
	
	character.velocity = Vector2.ZERO


func process_grind(delta: float) -> void:
	if not current_rail: return
	
	current_offset += (current_speed * grind_direction) * delta
	var total_length = current_curve.get_baked_length()
	
	if current_offset > total_length or current_offset < 0:
		exit_grind(Global.ReasonToExitGrind.END_OF_RAIL)
		return
	
	if controller.is_jumped():
		exit_grind(Global.ReasonToExitGrind.JUMPED)
		return
	
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
