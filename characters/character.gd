class_name BaseCharacter
extends CharacterBody2D

# --- Componentes Base ---
var trick_system:    TrickSystem
var equipment:       EquipmentManager
var controller:      PlayerController
var foot_ref:        CollisionShape2D
var grind_component: GrindComponent

# --- Flags e Estados (Reduzidos) ---
var is_locked:     bool = false
var is_trick_fail: bool = false
var can_jump:      bool = true
var can_move:      bool = true

var _is_jumping: bool  = false
var _jumped:     int   = 0
var _is_moving:  bool  = false

var current_boost_speed: float = 0.0

	# --- Grind flag ---
var available_grindable: GrindableObject = null

# ---------------------------------------------------------------------------
# API de Grind
# ---------------------------------------------------------------------------

func add_available_grindable(grindable: GrindableObject) -> void:
	available_grindable = grindable

func remove_available_grindable(grindable: GrindableObject) -> void:
	# Só remove se for o mesmo cano (previne bugs ao encostar em dois canos juntos)
	if available_grindable == grindable:
		available_grindable = null

# O character está ativamente grindando se o GrindComponent disser que está.
func is_grinding() -> bool:
	return grind_component != null and grind_component.is_grinding

# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------

func reset_jump()          -> void:  _jumped = 0
func can_grind()           -> bool:  return available_grindable != null
func is_jumping()          -> bool:  return _is_jumping
func jumped()              -> bool:  return _jumped > 0
func is_moving()           -> bool:  return _is_moving
func get_max_boost_speed() -> float: return equipment.current_equipment.max_boost_speed

# ---------------------------------------------------------------------------
# Movement methods
# ---------------------------------------------------------------------------

func _calculate_velocity() -> void:
	_apply_movement()
	_apply_jump()


func _apply_movement() -> void: pass
func _apply_jump()     -> void: pass


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		_is_jumping = false
		_jumped     = 0


func _update_moving_state() -> void:
	_is_moving = abs(velocity.x) > 1.0

# ---------------------------------------------------------------------------
# Lock / Unlock (platform / external movers)
# ---------------------------------------------------------------------------

@warning_ignore("unused_parameter")
func _is_on_grinding(grindable: GrindableObject) -> void: pass
func on_lock_character(_body: BaseCharacter)     -> void: pass
func on_unlock_character()                       -> void: pass
