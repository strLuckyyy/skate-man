@tool
class_name PropLineSpawner
extends RefCounted


static func bake_props(
	scene: PackedScene,
	container: Node2D,
	start_global: Vector2,
	end_global: Vector2,
	profile: RailProfile2D,
	scene_root: Node
) -> Array[Node2D]:
	var spawned: Array[Node2D] = []

	if scene == null or container == null or profile == null:
		return spawned

	_remove_generated_props(container)

	var delta := end_global - start_global
	var length := delta.length()

	if length < 1.0:
		return spawned

	var direction := delta / length
	var spacing := maxf(1.0, profile.prop_spacing)
	var margin := clampf(profile.prop_end_margin, 0.0, length * 0.5)
	var usable_length := length - margin * 2.0

	if usable_length <= 0.0:
		return spawned

	var rng := RandomNumberGenerator.new()
	rng.seed = profile.prop_seed

	var distance := maxf(0.0, profile.prop_start_offset)
	var safety_count := 0

	while distance <= usable_length and safety_count < 4096:
		var created: Node = scene.instantiate()

		if not created is Node2D:
			created.free()
			push_warning(
				"PropLineSpawner: a raiz de prop_scene precisa ser Node2D."
			)
			break

		var instance := created as Node2D
		container.add_child(instance)

		instance.global_position = (
			start_global + direction * (margin + distance)
		)

		if profile.align_props_to_segment:
			instance.global_rotation = direction.angle()

		instance.set_meta("rail_prop_generated", true)

		if scene_root != null:
			instance.owner = scene_root

		spawned.append(instance)

		var step := spacing

		if profile.prop_spacing_jitter > 0.0:
			step += rng.randf_range(
				-profile.prop_spacing_jitter,
				profile.prop_spacing_jitter
			)

		distance += maxf(1.0, step)
		safety_count += 1

	return spawned


static func _remove_generated_props(container: Node2D) -> void:
	for child in container.get_children():
		if child.has_meta("rail_prop_generated"):
			child.free()
