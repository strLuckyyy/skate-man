class_name GrindArea
extends Area2D

func _get_grindable() -> GrindableObject:
	var p := get_parent()
	while p != null:
		if p is GrindableObject:
			return p as GrindableObject
		p = p.get_parent()
	push_error("GrindArea: no GrindableObject ancestor found for %s" % get_path())
	return null

func _on_body_entered(body: Node2D) -> void:
	if body is BaseCharacter:
		var grindable = _get_grindable()
		if grindable:
			body.add_available_grindable(grindable)

func _on_body_exited(body: Node2D) -> void:
	if body is BaseCharacter:
		var grindable = _get_grindable()
		if grindable:
			body.remove_available_grindable(grindable)
