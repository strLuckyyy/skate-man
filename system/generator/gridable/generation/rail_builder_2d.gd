@tool
class_name RailBuilder2D
extends RefCounted


static func build_curve(
	target_path: Path2D,
	start_global: Vector2,
	end_global: Vector2,
	profile: RailProfile2D
) -> Curve2D:
	if target_path == null or profile == null:
		return null

	var start := target_path.to_local(start_global)
	var finish := target_path.to_local(end_global)
	var delta := finish - start

	if delta.length_squared() < 1.0:
		push_warning("RailBuilder2D: início e fim estão muito próximos.")
		return null

	var curve := Curve2D.new()
	curve.bake_interval = maxf(2.0, profile.curve_bake_interval)

	# Tangentes controlam a curvatura do fio entre os marcadores.
	var handle_x := delta.x / 3.0
	var sag := maxf(0.0, profile.sag_amount)

	curve.add_point(
		start,
		Vector2.ZERO,
		Vector2(handle_x, sag)
	)

	curve.add_point(
		finish,
		Vector2(-handle_x, sag),
		Vector2.ZERO
	)

	return curve
