class_name GrindComponent
extends Node

signal grind_finished(reason: Global.ReasonToExitGrind, data: Dictionary)

const MIN_ENTRY_SPEED: float = 300.0

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


func can_start_grind(rail: GrindableObject, entry_velocity: Vector2) -> bool:
	if rail == null:
		return false

	var curve := rail.get_curve()
	if curve == null or curve.get_baked_length() <= 0.0:
		return false

	return _get_entry_speed(entry_velocity) >= MIN_ENTRY_SPEED


func start_grind(rail: GrindableObject, entry_velocity: Vector2) -> bool:
	if not can_start_grind(rail, entry_velocity):
		return false

	is_grinding   = true
	current_rail  = rail
	current_curve = rail.get_curve()

	var local_pos = current_rail.path.to_local(character.global_position)
	current_offset = current_curve.get_closest_offset(local_pos)

	grind_direction = _get_entry_direction(entry_velocity)
	current_speed = _get_entry_speed(entry_velocity)

	character.velocity = Vector2.ZERO
	return true


func process_grind(delta: float) -> void:
	if not is_grinding or current_rail == null or current_curve == null:
		return

	current_offset += (current_speed * grind_direction) * delta
	var total_length = current_curve.get_baked_length()

	if current_offset > total_length or current_offset < 0:
		exit_grind(Global.ReasonToExitGrind.END_OF_RAIL)
		return

	if controller.is_jumped():
		exit_grind(Global.ReasonToExitGrind.JUMPED)
		return

	var new_local_pos = current_curve.sample_baked(current_offset)
	character.global_position = current_rail.path.to_global(new_local_pos)
	character.velocity = Vector2.ZERO


func exit_grind(reason: Global.ReasonToExitGrind) -> void:
	is_grinding   = false
	current_rail  = null
	current_curve = null
	var data = {
		"direction": grind_direction,
		"speed":     current_speed
	}
	grind_finished.emit(reason, data)


func _get_entry_speed(entry_velocity: Vector2) -> float:
	var boost_speed := character.current_boost_speed if character != null else 0.0
	return abs(entry_velocity.x) + boost_speed


func _get_entry_direction(entry_velocity: Vector2) -> float:
	if abs(entry_velocity.x) > 0.01:
		return sign(entry_velocity.x)
	return controller.direction if controller != null else 1.0
