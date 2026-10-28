extends Node2D

@onready var colision_area := $Area2D/CollisionShape2D
@onready var anim := $AnimationPlayer


func restart():
	anim.play("RESET")


func _on_area_2d_body_entered(body: BaseCharacter) -> void:
	body.trick_fail()
	anim.play("cone_anim/down")
