@tool
extends Path2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	
	if curve and not curve.changed.is_connected(_update_line):
		curve.changed.connect(_update_line)
	_update_line()

func _update_line() -> void:
	var line: Line2D = get_node_or_null("Line2D")
	if not line or not curve: return
		
	# get_baked_points() trará toda a suavização da parábola do fio perfeitamente!
	line.points = curve.get_baked_points()
