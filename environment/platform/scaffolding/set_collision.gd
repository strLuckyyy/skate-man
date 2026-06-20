extends AnimatableBody2D


@export var collision: CollisionShape2D

func _on_waiting_area_body_entered(body: Node2D) -> void:
	if body is BaseCharacter:
		var b = body as BaseCharacter
		var o = owner as ElevatorPlatform
		if o.need_jump and not b.controller.is_jumped(): return
		
		var y_pos = body.global_position.y + body.collision_shape.shape.get_height()
		collision.global_position.y = y_pos
		collision.set_deferred("disabled", false)
