class_name GrindArea
extends Area2D


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _get_grindable() -> ObjectGrindable:
	var p := get_parent()
	while p != null:
		if p is ObjectGrindable:
			return p as ObjectGrindable
		p = p.get_parent()
	push_error("GrindArea: no ObjectGrindable ancestor found for %s" % get_path())
	return null

# ---------------------------------------------------------------------------
# Signal callbacks (wired in grind_area.tscn)
# ---------------------------------------------------------------------------

func _on_body_entered(body: Node2D) -> void:
	if body is not BaseCharacter:
		return
	var grindable := _get_grindable()
	if grindable == null:
		return
	(body as BaseCharacter).on_grinding_area(true, grindable)


func _on_body_exited(body: Node2D) -> void:
	if body is not BaseCharacter:
		return
	(body as BaseCharacter).on_grinding_area(false, null)
