class_name ElevatorPlatform
extends BasePlatform

signal has_arrived
signal platform_timeout

enum AnimName { MOVE_UP, MOVE_DOWN }

@onready var elevator_door:  CollisionShape2D = $AnimatableBody2D/ElevatorDoor
@onready var elevator_timer: Timer            = $AnimatableBody2D/Timer

@export var can_down: bool

const ANIM_NAMES: Dictionary = {
	AnimName.MOVE_UP: "elevator/move_up",
	AnimName.MOVE_DOWN: "elevator/move_down",
}

var _current_anim: AnimName

# ---------------------------------------------------------------------------
# Overrides
# ---------------------------------------------------------------------------


func _ready() -> void:
	super._ready()
	elevator_door.set_process(false)
	elevator_timer.stop()


func set_platform_enabled(enabled: bool) -> void:
	super.set_platform_enabled(enabled)

# ---------------------------------------------------------------------------
# Movement flow
# ---------------------------------------------------------------------------

func start(dir: AnimName = AnimName.MOVE_UP) -> void:
	super.start()
	_anim_platform.play(ANIM_NAMES[dir])
	_current_anim = dir


func exit() -> void:
	elevator_timer.stop()
	
	if _current_character:
		_disconnect_character(_current_character)
		_current_character = null
	
	super.exit()
	
	_path_follow.progress_ratio = 0.0
	
	_wait_area.set_deferred("monitoring", true)
	platform_timeout.emit()

# ---------------------------------------------------------------------------
# Sync character × platform during movement
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _current_character and not _is_centering:
		_current_character.global_position = get_board_position()
		_current_character.velocity = Vector2.ZERO

# ---------------------------------------------------------------------------
# Callbacks
# ---------------------------------------------------------------------------

## Override do método virtual da BasePlataform.
func _on_character_centered() -> void:
	start(AnimName.MOVE_UP)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != ANIM_NAMES[_current_anim]:
		return

	match _current_anim:
		AnimName.MOVE_UP:
			_anim_platform.stop(true)
			elevator_door.disabled = true
			elevator_timer.start()
			has_arrived.emit()
		AnimName.MOVE_DOWN:
			exit()
		_:
			push_error("ElevatorPlatform: animação inesperada: %s" % anim_name)


func _on_timer_timeout() -> void:
	elevator_timer.stop()
	
	if _current_character:
		unlock_character.emit()
		_disconnect_character(_current_character)
		_current_character = null
	
	if can_down: start(AnimName.MOVE_DOWN)
	
	super.exit()
