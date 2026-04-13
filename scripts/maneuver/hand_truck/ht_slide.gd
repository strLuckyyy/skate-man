class_name HT_Slide
extends Maneuver

var normal_slide: TrickInfo = TrickInfo.new(
	0, 120, true, 1.5, [
		Utils.Direction.DOWN,
		], true, normal_update
)

var lateral_slide: TrickInfo = TrickInfo.new(
	1, 130, true, 2., [
		Utils.Direction.DOWN
	], true, lateral_update
)

var point_slide: TrickInfo = TrickInfo.new(
	2, 135, true, 2.2, [
		Utils.Direction.RIGHT,
		Utils.Direction.DOWN
	], true, point_update
)

func _ready() -> void:
	maneuvers.append(normal_slide)
	maneuvers.append(lateral_slide)
	maneuvers.append(point_slide)


func normal_update():
	normal_slide.debug_print()


func lateral_update():
	lateral_slide.debug_print()


func point_update():
	point_slide.debug_print()
