class_name BaseCharacter
extends CharacterBody2D

# --- Componentes Base ---
var state_machine:      StateMachine
var trick_system:       TrickSystem
var equipment:          EquipmentManager
var controller:         Controller
var collision_shape:    CollisionShape2D
var grind_component:    GrindComponent
var boost_component:    BoostComponent
var character_animator: CharacterAnimator
var animation_player:   AnimationPlayer

var _out_equip_data:    EquipmentData

# --- End Game flag ---
var is_caught: bool = false

# --- Grind flag ---
var available_grindable: GrindableObject = null

# --- Boost flag ---
var current_boost_speed: float = 0.0

# --- Angle flag ---
var smoothed_floor_angle: float = 0.0

# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------

func get_caught() -> void:
	EventBus.character_caught.emit(self)

func get_max_boost_speed() -> float:
	if equipment == null: push_error("equipment is null. ", equipment)
	if equipment.current_equipment == null: push_error("does not have equipment equip. ", equipment.current_equipment)
	return equipment.current_equipment.max_boost_speed


func equip(_equipment: EquipmentData) -> void:
	_out_equip_data = _equipment


func _ready() -> void:
	collision_shape    = $CollisionShape2D
	state_machine      = %StateMachine
	trick_system       = %TrickSystem
	boost_component    = %BoostComponent
	equipment          = %EquipmentManager
	controller         = %Controller
	grind_component    = %GrindComponent
	character_animator = %CharacterAnimator
	animation_player   = %AnimationPlayer
	
	boost_component.   setup(self)
	grind_component.   setup(self)
	character_animator.setup(self)
	state_machine.     setup(self)
	if _out_equip_data != null: equipment.equip(_out_equip_data)
	
	trick_system.grind_trick_requested.connect(_on_grind_trick_requested)
	boost_component.boost_update.connect(func(speed: float):
		current_boost_speed = speed
		print(current_boost_speed)
	)
	
	controller.is_locked = true


func _physics_process(delta: float) -> void:
	if controller != null: apply_gravity(delta)
	apply_slope_rotation(delta)


func start_race():
	controller.is_locked = false


func end_race():
	controller.is_locked = true

# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func apply_push(_forced := false) -> void: pass

func apply_momentum(floor_normal: Vector2) -> void:
	velocity = controller.apply_momentum(
		get_physics_process_delta_time(),
		velocity, 
		is_on_floor(), 
		floor_normal, 
		equipment.current_equipment,
		current_boost_speed
	)


func apply_slope_rotation(delta: float) -> void:
	var target_floor_angle: float = 0.0
	
	if is_on_floor() and not is_grinding():
		target_floor_angle = get_floor_normal().angle() + (PI / 2.0)
	else:
		target_floor_angle = 0.0
	
	var target_smoothing_speed: float = 5.0 
	
	if abs(velocity.x) > 300:
		target_smoothing_speed = 3.0
	
	smoothed_floor_angle = lerp_angle(smoothed_floor_angle, target_floor_angle, 
		target_smoothing_speed * delta)
	
	rotation = lerp_angle(rotation, smoothed_floor_angle, 15.0 * delta)


func apply_jump(mult: float = 1.0) -> void:
	var m = mult if mult != 0.0 else 1.0
	velocity = controller.apply_jump(velocity, equipment.current_equipment) * m


func apply_gravity(delta: float) -> void:
	if is_grinding():     return
	if not is_on_floor(): velocity += get_gravity() * delta; return
	controller.is_jumping = false
	controller.reset_jumped()

# ---------------------------------------------------------------------------
# API de Grind
# ---------------------------------------------------------------------------

func add_available_grindable(grindable: GrindableObject) -> void:
	available_grindable = grindable


func _on_grind_trick_requested(grindable: GrindableObject) -> void:
	var state := state_machine.get_current_state_id()
	
	if controller.jumped == 0: return
	if grindable == null: return
	if state != Global.StateID.ON_AIR and state != Global.StateID.ON_FALLING: return
	
	state_machine.transition_to(Global.StateID.ON_GRIDING, grindable)


func can_grind() -> bool: 
	return available_grindable != null

func is_grinding() -> bool:
	return grind_component != null and grind_component.is_grinding


func remove_available_grindable(grindable: GrindableObject) -> void:
	if available_grindable == grindable: available_grindable = null

func _is_on_grinding(_grindable: GrindableObject) -> void: pass

# ---------------------------------------------------------------------------
# Lock and Unlock
# ---------------------------------------------------------------------------

func on_lock_character(_body: BaseCharacter) -> void:
	velocity = Vector2.ZERO
	controller.is_locked = true
	#state_machine.transition_to(Global.StateID.ON_PLATAFORM)
func on_unlock_character()                   -> void:
	controller.is_locked = false
	apply_push(true)
	#state_machine.transition_to(Global.StateID.ON_FLOOR)
