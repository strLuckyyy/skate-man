extends Node2D

@onready var colision_area := $Area2D/CollisionShape2D
@onready var anim := $AnimationPlayer


func restart():
	anim.play("RESET")


func _on_area_2d_body_entered(body: BaseCharacter) -> void:
	body.state_machine.current_state.transition_requested.emit(
		Global.StateID.TRICK_FAIL, null
	)
	anim.play("cone_anim/down")
