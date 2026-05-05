class_name HT_Slide
extends Maneuver

var normal_slide: TrickInfo = TrickInfo.new(
	0, 120, true, 1.5, [
		Utils.Direction.DOWN
	], [
		Utils.StateID.ON_SLIDE
	],
	true, normal_update
)

var lateral_slide: TrickInfo = TrickInfo.new(
	1, 130, true, 2., [
		Utils.Direction.DOWN,
		Utils.Direction.RIGHT
	], [
		Utils.StateID.ON_SLIDE
	],
	true, lateral_update
)

var point_slide: TrickInfo = TrickInfo.new(
	2, 135, true, 2.2, [
		Utils.Direction.DOWN,
		Utils.Direction.LEFT
	], [
		Utils.StateID.ON_SLIDE,
		Utils.StateID.ON_FLOOR
	],
	true, point_update
)

func _ready() -> void:
	maneuvers.append(normal_slide)
	maneuvers.append(lateral_slide)
	maneuvers.append(point_slide)


func make_slide():
	pass


func normal_update():
	print(normal_slide.method_name)


func lateral_update():
	print(lateral_slide.method_name)


func point_update():
	print(point_slide.method_name)
