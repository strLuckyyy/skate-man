class_name CranePlatform
extends BasePlatform

signal has_arrived
signal platform_timeout

enum AnimName { MOVE_UP, MOVE_DOWN }

@onready var push_char: CollisionShape2D = %PushCharacter

@export var can_back: bool

const ANIM_NAMES: Dictionary = {
	AnimName.MOVE_UP: "crane/move_right",
	AnimName.MOVE_DOWN: "crane/move_left",
}

var _current_anim: AnimName

func _ready() -> void:
	super._ready()

func set_platform_enabled(enabled: bool) -> void:
	super.set_platform_enabled(enabled)

func start(dir: AnimName = AnimName.MOVE_UP) -> void:
	super.start()
	_anim_platform.play(ANIM_NAMES[dir])
	_current_anim = dir

func exit() -> void:
	if _current_character:
		_disconnect_character(_current_character)
		_current_character = null
	
	super.exit()
	
	_path_follow.progress_ratio = 0.0
	
	_wait_area.set_deferred("monitoring", true)
	platform_timeout.emit()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _current_character and not _is_centering:
		_current_character.global_position = get_board_position()
		_current_character.velocity = Vector2.ZERO

## Override do método virtual da BasePlatform.
func _on_character_centered() -> void:
	var char_pos        = _current_character.global_position.x
	var char_shape_size = _current_character.collision_shape.shape.get_radius()
	var new_pos         = char_pos - char_shape_size
	
	push_char.global_position.x = new_pos
	push_char.set_deferred("disabled", false)
	start(AnimName.MOVE_UP)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != ANIM_NAMES[_current_anim]:
		return

	match _current_anim:
		AnimName.MOVE_UP:
			_anim_platform.stop(true)
			if _current_character:
				unlock_character.emit()
				_disconnect_character(_current_character)
				_current_character = null
			
			if can_back: start(AnimName.MOVE_DOWN)
			
			has_arrived.emit()
			super.exit()
		AnimName.MOVE_DOWN:
			exit()
		_:
			push_error("CranePlatform: animação inesperada: %s" % anim_name)
