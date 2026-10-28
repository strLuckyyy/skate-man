extends Node2D



func _on_area_2d_body_entered(body: BaseCharacter) -> void:
	body.trick_fail()
