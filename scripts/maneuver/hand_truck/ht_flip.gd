class_name HT_Flip
extends Maneuver


var back_flip: TrickInfo = TrickInfo.new(
	4, 350, false, 0., [
		Utils.Direction.LEFT,
		Utils.Direction.DOWN
	], true, back_update
)

var front_flip: TrickInfo = TrickInfo.new(
	5, 350, false, 0., [
		Utils.Direction.RIGHT,
		Utils.Direction.DOWN
	], true, front_update
)


func _ready() -> void:
	maneuvers.append(back_flip)
	maneuvers.append(front_flip)


func back_update():
	back_flip.debug_print()


func front_update():
	front_flip.debug_print()
