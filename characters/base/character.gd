class_name BaseCharacter
extends CharacterBody2D

# --- Componentes Base ---
var state_machine:      StateMachine
var trick_system:       TrickSystem
var equipment:          EquipmentManager
var controller:         BaseController
var foot_ref:           CollisionShape2D
var grind_component:    GrindComponent
var boost_component:    BoostComponent
var character_animator: CharacterAnimator
var animation_player:   AnimationPlayer

# --- End Game flag ---
var is_caught: bool = false

# --- Grind flag ---
var available_grindable: GrindableObject = null

# --- Boost flags ---
var current_boost_speed: float = 0.0

# ---------------------------------------------------------------------------
# Getters
# ---------------------------------------------------------------------------

func can_grind() -> bool: 
	return available_grindable != null

func is_grinding() -> bool:
	return grind_component != null and grind_component.is_grinding

func get_max_boost_speed() -> float:
	if equipment == null: push_error("equipment is null. ", equipment)
	if equipment.current_equipment == null: push_error("does not have equipment equip. ", equipment.current_equipment)
	return equipment.current_equipment.max_boost_speed


func _ready() -> void:
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
	
	boost_component.boost_update.connect(func(speed: float):
		current_boost_speed = speed
		print(current_boost_speed)
	)


func _physics_process(delta: float) -> void:
	if controller != null: apply_gravity(delta)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		controller.is_jumping = false
		controller.reset_jumped()

# ---------------------------------------------------------------------------
# API de Grind
# ---------------------------------------------------------------------------

func add_available_grindable(grindable: GrindableObject) -> void:
	available_grindable = grindable


func remove_available_grindable(grindable: GrindableObject) -> void:
	if available_grindable == grindable: available_grindable = null

# ---------------------------------------------------------------------------
# Abstract methods
# ---------------------------------------------------------------------------

@warning_ignore("unused_parameter")
func _is_on_grinding(grindable: GrindableObject) -> void: pass
func on_lock_character(_body: BaseCharacter)     -> void: pass
func on_unlock_character()                       -> void: pass
func get_caught()                                -> void:
	EventBus.character_caught.emit(self)
