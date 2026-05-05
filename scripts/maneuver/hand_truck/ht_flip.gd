class_name HT_Flip
extends Maneuver


var back_flip: TrickInfo = TrickInfo.new(
	4, 350, false, 0., [
		Utils.Direction.DOWN,
		Utils.Direction.LEFT
	], [
		Utils.StateID.ON_AIR,
		Utils.StateID.FALLING
	],
	 true, back_update
)

var front_flip: TrickInfo = TrickInfo.new(
	5, 350, false, 0., [
		Utils.Direction.DOWN,
		Utils.Direction.RIGHT
	], [
		Utils.StateID.ON_AIR,
		Utils.StateID.FALLING
	],
	true, front_update
)

var _flip_tween: Tween


func _ready() -> void:
	maneuvers.append(back_flip)
	maneuvers.append(front_flip)


func get_maneuver_states() -> Array[Utils.StateID]:
	var ar = [front_flip.state_allowed, back_flip.state_allowed]
	return ar


func back_update():
	flip(false)

func front_update():
	flip(true)


func flip(to_front: bool = true) -> void:
	if _flip_tween: _flip_tween.kill()
	_flip_tween = create_tween()
	
	var rot_degrees = character.rotation_degrees
	var rot = rot_degrees + 360. if to_front else rot_degrees - 360.
	
	_flip_tween.tween_property(character, "rotation_degrees", rot, 0.7)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
