class_name BasePlataform
extends Path2D


signal lock_player(body: CharacterBody2D)
signal unlock_player()
signal player_centered()

@onready var _path_follow: PathFollow2D     = $PathFollow2D
@onready var _anima_body:  AnimatableBody2D = $AnimatableBody2D
@onready var _wait_area:   WaitingArea      = $WaitingArea
@onready var _anim_player: AnimationPlayer  = $AnimationPlayer

const _CENTER_SNAP_THRESHOLD: float   = 2.0
@export var center_offset:    Vector2 = Vector2.ZERO
@export var centering_speed:  float   = 400.0

var _current_player: CharacterBody2D = null
var _is_centering:   bool            = false


func _ready() -> void:
	set_platform_enabled(false)
	_wait_area.player_entered.connect(_on_player_entered)


func _physics_process(delta: float) -> void:
	if _is_centering and _current_player:
		_process_centering(delta)

# ---------------------------------------------------------------------------
# Public flow
# ---------------------------------------------------------------------------

func start():
	set_platform_enabled(true)


func exit(): 
	set_platform_enabled(false)


func set_platform_enabled(enabled: bool) -> void:
	set_process(enabled)
	_path_follow.set_physics_process(enabled)
	_anima_body.set_physics_process(enabled)
	_anim_player.set_process(enabled)


# ---------------------------------------------------------------------------
# Auto centralization
# ---------------------------------------------------------------------------

## Return the global position where the player must be stop.
func get_board_position() -> Vector2:
	return _anima_body.global_position + center_offset
 
 
func _start_centering(body: CharacterBody2D) -> void:
	_current_player = body
	_is_centering   = true
	set_physics_process(true)
 

func _process_centering(delta: float) -> void:
	var target_x := get_board_position().x
	var diff_x   := target_x - _current_player.global_position.x
	
	if absf(diff_x) <= _CENTER_SNAP_THRESHOLD:
		# Só snapa X — não toca em Y, física cuida disso.
		_current_player.global_position.x = target_x
		_current_player.velocity          = Vector2.ZERO
		_is_centering                     = false
		set_physics_process(false)
		player_centered.emit()
		return
	
	_current_player.global_position.x = move_toward(
		_current_player.global_position.x,
		target_x,
		centering_speed * delta
	)


# ---------------------------------------------------------------------------
# Lock / Unlock — conexão explícita, sem ONE_SHOT, sem acúmulo
# ---------------------------------------------------------------------------
 
## Conecta lock e unlock ao player garantindo que não há duplicatas.
func _connect_player(body: CharacterBody2D) -> void:
	if not lock_player.is_connected(body.on_lock_player):
		lock_player.connect(body.on_lock_player)
	if not unlock_player.is_connected(body.on_unlock_player):
		unlock_player.connect(body.on_unlock_player)
 
 
## Desconecta lock e unlock com segurança antes de liberar a referência.
func _disconnect_player(body: CharacterBody2D) -> void:
	if lock_player.is_connected(body.on_lock_player):
		lock_player.disconnect(body.on_lock_player)
	if unlock_player.is_connected(body.on_unlock_player):
		unlock_player.disconnect(body.on_unlock_player)
 

# ---------------------------------------------------------------------------
# Callbacks
# ---------------------------------------------------------------------------
 
func _on_player_entered(body: CharacterBody2D) -> void:
	_wait_area.set_deferred("monitoring", false)
	
	_connect_player(body)
	lock_player.emit(body)
	
	_start_centering(body)
	player_centered.connect(_on_player_centered, CONNECT_ONE_SHOT)
 
 
func _on_player_centered() -> void:
	# Subclasses implementam a lógica de movimento aqui.
	pass
