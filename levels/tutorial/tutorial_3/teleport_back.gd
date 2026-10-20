extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is not BaseCharacter: return
	var b := body as BaseCharacter
	
	var b_pos := b.global_position
	var to := Vector2(-1000, -500) + b_pos
	
	b.teleport_to(to)
