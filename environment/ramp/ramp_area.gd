class_name RampArea
extends StaticBody2D




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not BaseCharacter: return
	var b = body as BaseCharacter
	
	b.apply_external_impulse(Vector2(1000, 0))
