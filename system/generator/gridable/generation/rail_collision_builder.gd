@tool
class_name RailCollisionBuilder
extends RefCounted


static func bake_collision(
	grind_area: Area2D,
	source_path: Path2D,
	curve: Curve2D,
	thickness: float,
	scene_root: Node,
	enabled: bool = true
) -> CollisionPolygon2D:
	_remove_generated_collisions(grind_area)

	if not enabled:
		return null

	if grind_area == null or source_path == null or curve == null:
		return null

	var baked := curve.get_baked_points()

	if baked.size() < 2:
		return null

	var local_points := PackedVector2Array()
	local_points.resize(baked.size())

	for i in range(baked.size()):
		var global_point := source_path.to_global(baked[i])
		local_points[i] = grind_area.to_local(global_point)

	var half_width := maxf(1.0, thickness) * 0.5
	var count := local_points.size()
	var polygon := PackedVector2Array()
	polygon.resize(count * 2)

	for i in range(count):
		var tangent: Vector2

		if i == 0:
			tangent = local_points[1] - local_points[0]
		elif i == count - 1:
			tangent = local_points[i] - local_points[i - 1]
		else:
			tangent = local_points[i + 1] - local_points[i - 1]

		if tangent.length_squared() < 0.0001:
			tangent = Vector2.RIGHT

		var normal := Vector2(
			-tangent.normalized().y,
			tangent.normalized().x
		) * half_width

		polygon[i] = local_points[i] + normal
		polygon[count * 2 - 1 - i] = local_points[i] - normal

	var collision := CollisionPolygon2D.new()
	collision.name = "RailBakeCollision"
	collision.polygon = polygon
	collision.set_meta("rail_bake_generated", true)

	grind_area.add_child(collision)

	if scene_root != null:
		collision.owner = scene_root

	return collision


static func _remove_generated_collisions(grind_area: Area2D) -> void:
	if grind_area == null:
		return

	for child in grind_area.get_children():
		if (
			child is CollisionPolygon2D
			and child.has_meta("rail_bake_generated")
		):
			child.free()
