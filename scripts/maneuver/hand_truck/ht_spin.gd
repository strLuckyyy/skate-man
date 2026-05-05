class_name HT_Spin
extends Maneuver

var front_air_spin = TrickInfo.new(
	6, 350, false, 0., [
		Utils.Direction.UP,
		Utils.Direction.RIGHT
	], [
		Utils.StateID.ON_FLOOR,
		Utils.StateID.ON_AIR,
		Utils.StateID.FALLING
	],
	true, front_air_update
)

var back_air_spin = TrickInfo.new(
	7, 350, false, 0., [
		Utils.Direction.UP,
		Utils.Direction.LEFT
	], [
		Utils.StateID.ON_FLOOR,
		Utils.StateID.ON_AIR,
		Utils.StateID.FALLING
	],
	true, back_air_update
)

var spin_floor = TrickInfo.new(
	8, 280, false, 0., [
		Utils.Direction.LEFT,
		Utils.Direction.DOWN,
		Utils.Direction.RIGHT
	], [
		Utils.StateID.ON_FLOOR,
		Utils.StateID.ON_AIR,
		Utils.StateID.FALLING
	],
	false, floor_update
)

var current_spin_time = 0.0
var can_front_air = true
var can_back_air = true
var can_spin = true


func set_can_value(value: bool):
	can_back_air = value
	can_front_air = value
	can_spin = value


func control_time(trick: TrickInfo, delta: float) -> void:
	current_spin_time += delta
	print(current_spin_time)
	if current_spin_time >= trick.cd_timeout:
		current_spin_time = 0.0
		set_can_value(true)

func _ready() -> void:
	maneuvers.append(front_air_spin)
	maneuvers.append(back_air_spin)
	maneuvers.append(spin_floor)


func _physics_process(delta: float) -> void:
	if not can_back_air:
		control_time(back_air_spin, delta)
	if not can_front_air:
		control_time(front_air_spin, delta)
	if not can_spin:
		control_time(spin_floor, delta)


func front_air_update():
	if not can_front_air: return
	character.force_jump()
	spin()
	set_can_value(false)


func back_air_update():
	if not can_back_air: return
	character.force_jump()
	spin()
	set_can_value(false)


func floor_update():
	if not can_spin: return
	spin()
	set_can_value(false)


func spin():
	var tween = create_tween()
	tween.tween_property(character, "scale:x", 0.0, 0.35)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(character, "scale:x", -1.0, 0.35)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.kill()
	
	tween = create_tween()
	tween.tween_property(character, "scale:x", -1.0, 0.35)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(character, "scale:x", 1.0, 0.35)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	character.scale = Vector2(1., 1.)
