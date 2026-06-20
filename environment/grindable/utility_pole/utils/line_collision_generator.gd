@tool
class_name LineCollisionGenerator
extends RefCounted

static func generate_single_grind_collision(
	grind_area: Area2D,
	curve: Curve2D,
	thickness: float,
	scene_root: Node
) -> void:
	if not grind_area or not curve: return
	
	# Remove colisores antigos
	for child in grind_area.get_children():
		if child is CollisionPolygon2D:
			child.free()
	
	var baked := curve.get_baked_points()
	if baked.size() < 2: return
	
	var polygon := PackedVector2Array()
	
	# Borda superior (cima)
	for p in baked:
		polygon.append(p + Vector2(0, -thickness))
	# Borda inferior (baixo) em ordem inversa
	for i in range(baked.size() - 1, -1, -1):
		polygon.append(baked[i] + Vector2(0, thickness))
	
	var col := CollisionPolygon2D.new()
	col.polygon = polygon
	grind_area.add_child(col)
	
	if Engine.is_editor_hint() and scene_root:
		col.owner = scene_root
