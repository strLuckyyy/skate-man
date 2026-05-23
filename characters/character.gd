class_name BaseCharacter
extends CharacterBody2D


var trick_system: TrickSystem
var equipment:    EquipmentManager
var controller:   PlayerController
var foot_ref:     CollisionShape2D

# --- Blocking State ---
## When true, all controllers (input and automatic) are disabled.
## The external node sets the pos via global_position.
var is_locked: bool = false

# --- Animation flags ---
var is_waiting:    bool = false
var is_caught:     bool = false
var is_trick_fail: bool = false

# --- Gameplay flags ---
var can_jump:  bool = true
var can_grind: bool = false
var can_move:  bool = true
var can_trick: bool = true #this flag will be used in animation tree transitions - while some trick is been executed, can_trick = false. 

var _is_jumping: bool  = false
var _jumped:     int   = 0
var _is_moving:  bool  = false
var _is_grinding: bool = false #this flag will be used in animation tree transitions - while

var _current_grindable: ObjectGrindable = null

# --- Boost flags ---
var current_boost_speed: float = 0.0

# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------

func is_jumping()          -> bool:    return _is_jumping
func is_grinding()         -> bool:    return _is_grinding
func is_moving()           -> bool:    return _is_moving
func get_foot_position()   -> Vector2: return foot_ref.global_position
func reset_jump()          -> void:    _jumped = 0
func get_max_boost_speed() -> float:   return equipment.current_equipment.max_boost_speed

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
# Grind API
# ---------------------------------------------------------------------------

func on_grinding_area(_can_grind: bool, grindable: ObjectGrindable = null) -> void:
	can_grind          = _can_grind
	_current_grindable = grindable


func start_grind() -> void:
	_is_grinding = true


func stop_grind() -> void:
	_is_grinding       = false
	_current_grindable = null
	can_grind          = false


# ---------------------------------------------------------------------------
# Lock / Unlock (platform / external movers)
# ---------------------------------------------------------------------------

@warning_ignore("unused_parameter")
func _is_on_grinding(grindable: ObjectGrindable) -> void: pass
func on_lock_character(_body: BaseCharacter)     -> void: pass
func on_unlock_character()                       -> void: pass
