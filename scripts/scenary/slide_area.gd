class_name SlideArea
extends Area2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	collision_shape.shape.size = sprite.texture.get_size()


func _on_body_entered(body: BaseCharacter) -> void:
	print("enter", body.name)
	body.set_state_to_slide(true)


func _on_body_exited(body: BaseCharacter) -> void:
	print("exit", body.name)
	body.set_state_to_slide(false)
