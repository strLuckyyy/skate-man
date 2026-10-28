@tool
class_name RailVisualBuilder
extends RefCounted


static func bake_visual(
	target_path: Path2D,
	profile: RailProfile2D,
	scene_root: Node
) -> void:
	if target_path == null or profile == null:
		return

	_remove_generated_lines(target_path)

	if not profile.draw_line or target_path.curve == null:
		return

	var base_points := target_path.curve.get_baked_points()

	if base_points.size() < 2:
		return

	var offsets := profile.visual_offsets

	if offsets.is_empty():
		offsets = PackedFloat32Array([0.0])

	for i in range(offsets.size()):
		var offset := offsets[i]
		var points := _offset_points(base_points, offset)

		var line := Line2D.new()
		line.name = "RailLine_%02d" % i
		line.points = points
		line.width = profile.visual_width
		line.texture = profile.line_texture
		line.texture_mode = profile.texture_mode
		line.default_color = profile.line_color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.z_index = profile.visual_z_index
		line.set_meta("rail_bake_generated", true)

		target_path.add_child(line)

		if scene_root != null:
			line.owner = scene_root


static func _offset_points(
	base_points: PackedVector2Array,
	offset: float
) -> PackedVector2Array:
	var result := PackedVector2Array()
	result.resize(base_points.size())

	for i in range(base_points.size()):
		var tangent: Vector2

		if i == 0:
			tangent = base_points[1] - base_points[0]
		elif i == base_points.size() - 1:
			tangent = base_points[i] - base_points[i - 1]
		else:
			tangent = base_points[i + 1] - base_points[i - 1]

		if tangent.length_squared() < 0.0001:
			result[i] = base_points[i]
			continue

		var normal := Vector2(
			-tangent.normalized().y,
			tangent.normalized().x
		)

		result[i] = base_points[i] + normal * offset

	return result


static func _remove_generated_lines(target_path: Path2D) -> void:
	for child in target_path.get_children():
		if child is Line2D and child.has_meta("rail_bake_generated"):
			child.free()
