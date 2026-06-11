class_name Controller
extends Node

var is_locked:     bool  = false
var is_trick_fail: bool  = false
var can_jump:      bool  = true
var can_move:      bool  = true
var is_jumping:    bool  = false
var is_moving:     bool  = false
var jumped:        int   = 0

var direction: float = 1.0 # 1.0 direita; -1.0 esquerda

# --- TIMERS PARA COOLDOWN DE REMADA ---
# Se quiser impedir que o jogador "spamme" o botão de remar
var _push_cooldown: float = 0.4
var _last_push_time: float = 0.0

func is_jumped()    -> bool: return jumped > 0
func reset_jumped() -> void: jumped = 0

func set_permissions(can_move_val: bool = true, can_jump_val: bool = true) -> void:
	self.can_move = can_move_val; self.can_jump = can_jump_val

func change_direction(dir: Global.Direction) -> void:
	if dir == Global.Direction.RIGHT: direction = 1.0
	elif dir == Global.Direction.LEFT: direction = -1.0

func update_moving_state(velocity: Vector2) -> void:
	# Ajustei para > 5.0 para evitar que micro-deslizamentos contem como movimento
	is_moving = abs(velocity.x) > 5.0 

# ==========================================
# 🛹 NOVO SISTEMA DE FÍSICA
# ==========================================

## 1. O EVENTO (A Remada)
func apply_push(velocity: Vector2, equipment: EquipmentData) -> Vector2:
	if not can_move: return velocity
	
	# Checa o cooldown para o jogador não metralhar o botão e voar pelo mapa
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_push_time < _push_cooldown:
		return velocity
		
	_last_push_time = current_time

	# Injeção instantânea de velocidade (Burst)
	# Assumindo que seu equipment tem uma variável tipo push_power ou acceleration
	var burst_force = 400.0 # Substitua por: equipment.push_modifier (ex: 400.0)
	
	velocity.x += burst_force * direction
	
	# Trava na velocidade máxima para não estourar a física
	var cap = equipment.max_speed
	velocity.x = clamp(velocity.x, -cap, cap)
	
	return velocity


## 2. O EMBALO CONTÍNUO (Ladeira e Atrito)
func apply_momentum(velocity: Vector2, is_on_floor: bool, floor_normal: Vector2, delta: float, equipment: EquipmentData) -> Vector2:
	if not can_move: return velocity

	# A) Gravidade da Ladeira
	if is_on_floor and floor_normal != Vector2.UP:
		var slope_gravity = 1500.0 # O quão forte a ladeira te empurra
		# floor_normal.x aponta a direção da descida naturalmente
		velocity.x += floor_normal.x * slope_gravity * delta

	# B) Atrito e Desaceleração Natural
	# Usamos move_toward em vez de lerp. Lerp nunca chega a zero de verdade, 
	# move_toward puxa de forma linear e estaciona em zero.
	var current_friction = equipment.friction if is_on_floor else (equipment.friction * 0.1)
	
	# Como sua friction provavelmente é algo entre 0 e 1, multiplicamos por um escalar
	var friction_force = current_friction * 1000.0 
	
	velocity.x = move_toward(velocity.x, 0.0, friction_force * delta)

	# Trava o personagem completamente se ele estiver bem devagar no chão reto
	if abs(velocity.x) < 5.0 and floor_normal == Vector2.UP:
		velocity.x = 0.0

	return velocity


func apply_jump(velocity: Vector2, equipment_data: EquipmentData) -> Vector2:
	if can_jump and jumped == 0:
		jumped    += 1
		is_jumping = true
		velocity.y = -equipment_data.jump_modifier
	return velocity
