class_name ElevatorPlataform
extends BasePlataform

signal has_arrived
signal platform_timeout

enum AnimName { MOVE_UP, MOVE_DOWN }

@onready var elevator_door:  CollisionShape2D = $AnimatableBody2D/ElevatorDoor
@onready var elevator_timer: Timer            = $AnimatableBody2D/Timer

const ANIM_NAMES: Dictionary = {
	AnimName.MOVE_UP:   "elevator/move_up",
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
	# NÃO toca no timer aqui — o timer é gerenciado manualmente
	# em start() e exit() para evitar reativação com estado sujo.


# ---------------------------------------------------------------------------
# Movement flow
# ---------------------------------------------------------------------------

func start(dir: AnimName = AnimName.MOVE_UP) -> void:
	super.start()
	_anim_player.play(ANIM_NAMES[dir])
	_current_anim = dir


func exit() -> void:
	# 1. Para o timer ANTES de qualquer outra coisa — evita disparo espúrio.
	elevator_timer.stop()

	# 2. Desconecta e solta o player se ainda houver referência.
	if _current_player:
		_disconnect_player(_current_player)
		_current_player = null

	# 3. Desativa a plataforma (para física, animação, etc.)
	super.exit()

	# 4. Reseta a posição — feito DEPOIS de desativar para que o
	#    _physics_process não arraste o player para a posição resetada.
	_path_follow.progress_ratio = 0.0

	# 5. Só agora reativa o monitoring — plataforma já está na origem.
	_wait_area.set_deferred("monitoring", true)

	platform_timeout.emit()


# ---------------------------------------------------------------------------
# Sync player × platform during movement
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if _current_player and not _is_centering:
		_current_player.global_position = get_board_position()
		_current_player.velocity        = Vector2.ZERO


# ---------------------------------------------------------------------------
# Callbacks
# ---------------------------------------------------------------------------

## Override do método virtual da BasePlataform.
func _on_player_centered() -> void:
	start(AnimName.MOVE_UP)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != ANIM_NAMES[_current_anim]:
		return

	match _current_anim:
		AnimName.MOVE_UP:
			# keep_state = true: mantém o último frame, sem teleporte para origem.
			_anim_player.stop(true)
			elevator_door.disabled = true
			elevator_timer.start()
			has_arrived.emit()

		AnimName.MOVE_DOWN:
			exit()

		_:
			push_error("ElevatorPlatform: animação inesperada: %s" % anim_name)


func _on_timer_timeout() -> void:
	# Para o timer imediatamente — evita disparo duplo se set_process
	# for reativado antes do próximo frame.
	elevator_timer.stop()

	if _current_player:
		unlock_player.emit()
		_disconnect_player(_current_player)
		_current_player = null

	start(AnimName.MOVE_DOWN)
