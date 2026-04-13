class_name HT_Spin
extends Maneuver

var front_air_spin = TrickInfo.new(
	6, 350, false, 0., [
		Utils.Direction.UP,
		Utils.Direction.RIGHT
	], true, front_air_update
)

var back_air_spin = TrickInfo.new(
	7, 350, false, 0., [
		Utils.Direction.UP,
		Utils.Direction.LEFT
	], true, back_air_update
)

var spin_floor = TrickInfo.new(
	8, 280, false, 0., [
		Utils.Direction.LEFT,
		Utils.Direction.DOWN,
		Utils.Direction.RIGHT
	], false, floor_update
)


func _ready() -> void:
	maneuvers.append(front_air_spin)
	maneuvers.append(back_air_spin)
	maneuvers.append(spin_floor)


func front_air_update():
	front_air_spin.debug_print()


func back_air_update():
	back_air_spin.debug_print()


func floor_update():
	spin_floor.debug_print()
