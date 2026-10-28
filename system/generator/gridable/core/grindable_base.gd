@tool
class_name GrindableObject
extends Node2D

@export_category("Rail")
@export var rail_profile: RailProfile2D

@export_category("Referências")
@export var rail_path_path: NodePath = ^"%Path2D"
@export var rail_area_path: NodePath = ^"%GrindArea"
@export var rail_start_path: NodePath
@export var rail_end_path: NodePath

# Mantido para compatibilidade com o script-base anterior.
@export var obstacle_data: ObstacleData = null

@export_category("Bake no editor")
@export_tool_button("Bake rail")
var bake_rail_button: Callable = bake_rail

@export_tool_button("Limpar bake")
var clear_rail_button: Callable = clear_rail_bake


## API que o sistema de grind pode continuar usando.
func get_curve() -> Curve2D:
	var target_path := _get_rail_path()
	if target_path == null:
		return null

	return target_path.curve


## API que o sistema de grind pode continuar usando.
func get_global_start_position() -> Vector2:
	var target_path := _get_rail_path()
	if target_path == null:
		return global_position

	return target_path.global_position


func bake_rail() -> void:
	if not Engine.is_editor_hint():
		push_warning("O bake do rail só pode ser executado no editor.")
		return

	if rail_profile == null:
		push_warning("%s: atribua um RailProfile2D." % name)
		return

	var target_path := _get_rail_path()
	var grind_area := _get_rail_area()
	var start_marker := _get_marker(
		rail_start_path,
		["RailStart", "WireStart"]
	)
	var end_marker := _get_marker(
		rail_end_path,
		["RailEnd", "WireEnd"]
	)

	if (
		target_path == null
		or grind_area == null
		or start_marker == null
		or end_marker == null
	):
		push_warning(
			"%s: confira Path2D, GrindArea e marcadores de início/fim."
			% name
		)
		return

	# Limpa apenas o conteúdo gerado por este sistema.
	_clear_generated_content(target_path, grind_area)

	var curve := RailBuilder2D.build_curve(
		target_path,
		start_marker.global_position,
		end_marker.global_position,
		rail_profile
	)

	if curve == null:
		push_warning("%s: falha ao gerar a curva." % name)
		return

	target_path.curve = curve

	var scene_root := _get_edited_scene_root()

	RailVisualBuilder.bake_visual(
		target_path,
		rail_profile,
		scene_root
	)

	RailCollisionBuilder.bake_collision(
		grind_area,
		target_path,
		curve,
		rail_profile.collision_thickness,
		scene_root,
		rail_profile.generate_collision
	)

	if rail_profile.spawn_props and rail_profile.prop_scene != null:
		var props_parent := get_node_or_null("GeneratedProps") as Node2D

		if props_parent == null:
			props_parent = Node2D.new()
			props_parent.name = "GeneratedProps"
			add_child(props_parent)

			if scene_root != null:
				props_parent.owner = scene_root

		PropLineSpawner.bake_props(
			rail_profile.prop_scene,
			props_parent,
			start_marker.global_position,
			end_marker.global_position,
			rail_profile,
			scene_root
		)

	update_configuration_warnings()


func clear_rail_bake() -> void:
	if not Engine.is_editor_hint():
		return

	var target_path := _get_rail_path()
	var grind_area := _get_rail_area()

	_clear_generated_content(target_path, grind_area)

	if target_path != null:
		target_path.curve = Curve2D.new()


func _clear_generated_content(
	target_path: Path2D,
	grind_area: Area2D
) -> void:
	if target_path != null:
		for child in target_path.get_children():
			if (
				child is Line2D
				and child.has_meta("rail_bake_generated")
			):
				child.free()

	if grind_area != null:
		for child in grind_area.get_children():
			if (
				child is CollisionPolygon2D
				and child.has_meta("rail_bake_generated")
			):
				child.free()

	var props_parent := get_node_or_null("GeneratedProps")

	if props_parent != null:
		for child in props_parent.get_children():
			if child.has_meta("rail_prop_generated"):
				child.free()


func _get_rail_path() -> Path2D:
	if not rail_path_path.is_empty():
		var configured := get_node_or_null(rail_path_path) as Path2D
		if configured != null:
			return configured

	return find_child("Path2D", true, false) as Path2D


func _get_rail_area() -> Area2D:
	if not rail_area_path.is_empty():
		var configured := get_node_or_null(rail_area_path) as Area2D
		if configured != null:
			return configured

	return find_child("GrindArea", true, false) as Area2D


func _get_marker(
	configured_path: NodePath,
	fallback_names: Array[String]
) -> Marker2D:
	if not configured_path.is_empty():
		var configured := get_node_or_null(configured_path) as Marker2D
		if configured != null:
			return configured

	for marker_name in fallback_names:
		var marker := find_child(marker_name, true, false) as Marker2D
		if marker != null:
			return marker

	return null


func _get_edited_scene_root() -> Node:
	if not Engine.is_editor_hint():
		return null

	return get_tree().edited_scene_root


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if rail_profile != null:
		if _get_rail_path() == null:
			warnings.append("Não foi encontrado um nó Path2D.")
		if _get_rail_area() == null:
			warnings.append("Não foi encontrado um nó GrindArea.")

	return warnings
