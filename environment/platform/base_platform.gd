class_name BasePlatform
extends Path2D

enum TargetCharacter { ANY, PLAYER, OPPONENT }

signal lock_character(body: BaseCharacter)
signal unlock_character()
signal character_centered()

const _CENTER_SNAP_THRESHOLD: float = 2.0

@onready var _path_follow:   PathFollow2D     = $PathFollow2D
@onready var _anima_body:    AnimatableBody2D = $AnimatableBody2D
@onready var _wait_area:     WaitingArea      = $WaitingArea
@onready var _anim_platform: AnimationPlayer  = $AnimationPlayer

@export var obstacle_data:    ObstacleData    = null
@export var target_character: TargetCharacter = TargetCharacter.ANY
@export var center_offset:    Vector2         = Vector2.ZERO
@export var centering_speed:  float           = 400.0

var _current_character: CharacterBody2D = null
var _is_centering:      bool            = false


func _ready() -> void:
	set_platform_enabled(false)
	_wait_area.character_entered.connect(_on_character_entered)
	_set_layer()


func _physics_process(delta: float) -> void:
	if _is_centering and _current_character:
		_process_centering(delta)


func _resolve_platform_layer(target: TargetCharacter) -> int:
	match target:
		TargetCharacter.PLAYER:   return 1 << 2  # Layer 3 — plataform_player
		TargetCharacter.OPPONENT: return 1 << 3  # Layer 4 — plataform_opponent
		_: return _anima_body.collision_layer    # fallback original


func _resolve_platform_mask(target: TargetCharacter) -> int:
	match target:
		TargetCharacter.PLAYER:   return 1 << 0  # Layer 1 — player
		TargetCharacter.OPPONENT: return 1 << 1  # Layer 2 — opponent
		_: return _anima_body.collision_mask


func _set_layer() -> void:
	var layer_bit := _resolve_platform_layer(target_character)
	var mask_bit  := _resolve_platform_mask(target_character)

	_anima_body.collision_layer = layer_bit
	_anima_body.collision_mask  = mask_bit
	_wait_area.collision_layer  = layer_bit
	_wait_area.collision_mask   = mask_bit

	_wait_area.target_character = target_character

# ---------------------------------------------------------------------------
# Public flow
# ---------------------------------------------------------------------------

func start() -> void: set_platform_enabled(true)
func exit()  -> void: set_platform_enabled(false)


func set_platform_enabled(enabled: bool) -> void:
	set_process(enabled)
	_path_follow.set_physics_process(enabled)
	_anima_body.set_physics_process(enabled)
	_anim_platform.set_process(enabled)

# ---------------------------------------------------------------------------
# Auto centralization
# ---------------------------------------------------------------------------

## Return the global position where the player must be stop.
func get_board_position() -> Vector2: return _anima_body.global_position + center_offset


func _start_centering(body: CharacterBody2D) -> void:
	_current_character = body
	_is_centering      = true
	set_physics_process(true)


func _process_centering(delta: float) -> void:
	var target_x := get_board_position().x
	var diff_x   := target_x - _current_character.global_position.x

	if absf(diff_x) <= _CENTER_SNAP_THRESHOLD:
		_current_character.global_position.x = target_x
		_current_character.velocity          = Vector2.ZERO
		_is_centering                        = false
		set_physics_process(false)
		character_centered.emit()
		return

	_current_character.global_position.x = move_toward(
		_current_character.global_position.x,
		target_x,
		centering_speed * delta,
	)

# ---------------------------------------------------------------------------
# Lock / Unlock — conexão explícita, sem ONE_SHOT, sem acúmulo
# ---------------------------------------------------------------------------

func _connect_character(body: BaseCharacter) -> void:
	if not lock_character.is_connected(body.on_lock_character):
		lock_character.connect(body.on_lock_character)
	if not unlock_character.is_connected(body.on_unlock_character):
		unlock_character.connect(body.on_unlock_character)


func _disconnect_character(body: BaseCharacter) -> void:
	if lock_character.is_connected(body.on_lock_character):
		lock_character.disconnect(body.on_lock_character)
	if unlock_character.is_connected(body.on_unlock_character):
		unlock_character.disconnect(body.on_unlock_character)

# ---------------------------------------------------------------------------
# Callbacks
# ---------------------------------------------------------------------------

func _on_character_entered(body: CharacterBody2D) -> void:
	_wait_area.set_deferred("monitoring", false)

	_connect_character(body)
	lock_character.emit(body)

	_start_centering(body)
	character_centered.connect(_on_character_centered, CONNECT_ONE_SHOT)


func _on_character_centered() -> void: pass
