class_name GrindArea
extends Area2D


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("on_grinding_area"):
		body.on_grinding_area(true, self)


func _on_body_exited(body: CharacterBody2D) -> void:
	if body.has_method("on_grinding_area"):
		body.on_grinding_area(false, self)
