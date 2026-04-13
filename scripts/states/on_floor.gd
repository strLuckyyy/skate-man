class_name OnFloor
extends State


func update(_delta: float) -> void:
	character.apply_movement()
	character.apply_jump()
