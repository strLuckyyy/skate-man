class_name OpponentAI
extends BaseCharacter

func _ready() -> void:
	super._ready()
	if %StateManager is not BTManager:
		push_error("In IA node, State Manager must be BTManager.")
	state_manager = %StateManager as BTManager
