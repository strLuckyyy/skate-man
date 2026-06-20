@tool
class_name LineCurveBuilder
extends RefCounted

static func build_single_curve(
	path: Path2D,
	poles: Array[Node2D],
	wire_start: Marker2D,
	wire_end: Marker2D,
	sag_amount: float
) -> Curve2D:
	if poles.is_empty(): return null
	if not path: return null
	
	var curve := Curve2D.new()
	
	# Ponto inicial (WireStart) no espaço local do Path
	curve.add_point(path.to_local(wire_start.global_position))
	
	# Conecta todos os postes
	for pole in poles:
		var left = pole.get_node_or_null("LeftAnchor") as Marker2D
		var right = pole.get_node_or_null("RightAnchor") as Marker2D
		if not left or not right: continue
		
		var local_left = path.to_local(left.global_position)
		var local_right = path.to_local(right.global_position)
		
		# Sag: metade do vão entre o último ponto e a âncora esquerda
		var prev_idx = curve.get_point_count() - 1
		var prev_pos = curve.get_point_position(prev_idx)
		var mid_x_in = (local_left.x - prev_pos.x) / 2.0
		
		curve.set_point_out(prev_idx, Vector2(mid_x_in, sag_amount))
		curve.add_point(local_left, Vector2(-mid_x_in, sag_amount), Vector2.ZERO)
		curve.add_point(local_right, Vector2.ZERO, Vector2.ZERO)
	
	# Ponto final (WireEnd)
	var local_end = path.to_local(wire_end.global_position)
	var last_idx = curve.get_point_count() - 1
	var last_pos = curve.get_point_position(last_idx)
	var mid_x_out = (local_end.x - last_pos.x) / 2.0
	
	curve.set_point_out(last_idx, Vector2(mid_x_out, sag_amount))
	curve.add_point(local_end, Vector2(-mid_x_out, sag_amount), Vector2.ZERO)
	
	path.curve = curve
	return curve
