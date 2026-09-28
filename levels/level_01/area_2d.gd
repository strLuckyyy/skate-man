extends Area2D


@export var roof: CollisionShape2D


func _on_body_exited(body: Node2D) -> void:
	if body is BaseCharacter:
		roof.set_deferred("disabled", false)
