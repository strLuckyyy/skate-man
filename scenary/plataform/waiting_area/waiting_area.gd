class_name WaitingArea
extends Area2D

signal player_entered(body: CharacterBody2D)
signal player_exited(body: CharacterBody2D)

func _on_body_entered(body: Node2D):
	if body is not CharacterBody2D: return
	player_entered.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body is not CharacterBody2D: return
	player_exited.emit(body)
