class_name OpponentAI
extends BaseCharacter

func _ready() -> void:
	super._ready()
	if %StateManager is not BTManager:
		push_error("In AI node, State Manager must be BTManager.")
	state_manager = %StateManager as BTManager


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	move_and_slide()
