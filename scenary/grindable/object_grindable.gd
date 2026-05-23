class_name ObjectGrindable
extends Path2D

@onready var player_anchor: PathFollow2D = $PlayerAnchor
@export var grind_speed: float = 200.0


# ---------------------------------------------------------------------------
# Public API — called by OnGridingState each physics frame
# ---------------------------------------------------------------------------

func snap_to_nearest(world_pos: Vector2) -> void:
	var local_pos := to_local(world_pos)
	player_anchor.progress = curve.get_closest_offset(local_pos)


func advance(amount: float) -> void:
	player_anchor.progress = clampf(
		player_anchor.progress + amount,
		0.0,
		get_total_length()
	)


func can_accept_speed(character_speed: float) -> bool:
	return grind_speed >= abs(character_speed)


func get_grind_position() -> Vector2:
	return player_anchor.global_position


func get_total_length() -> float:
	return curve.get_baked_length()


func get_height_at_nearest(world_pos: Vector2) -> float:
	var local_pos := to_local(world_pos)
	var offset    := curve.get_closest_offset(local_pos)
	return to_global(curve.sample_baked(offset)).y


func is_foot_aligned(foot_world_pos: Vector2, tolerance: float = 18.0) -> bool:
	return abs(foot_world_pos.y - get_height_at_nearest(foot_world_pos)) <= tolerance


func is_at_end() -> bool:
	return player_anchor.progress >= get_total_length() - 2.0


func is_at_start() -> bool:
	return player_anchor.progress <= 2.0


func get_exit_direction() -> Vector2:
	var saved   := player_anchor.progress
	var pos_a   := player_anchor.global_position
	
	player_anchor.progress = minf(saved + 4.0, get_total_length())
	var pos_b   := player_anchor.global_position
	
	player_anchor.progress = saved
	var dir := (pos_b - pos_a)
	return dir.normalized() if dir.length_squared() > 0.0 else Vector2.RIGHT


func reset_anchor() -> void:
	player_anchor.progress = 0.0
