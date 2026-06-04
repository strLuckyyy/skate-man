@tool
extends BTCondition

@export var target_state: Global.StateID

func _tick(_delta: float) -> Status:
	var character: BaseCharacter = agent as BaseCharacter
	
	if character == null or character.state_machine == null:
		return FAILURE
	
	if character.state_machine.get_current_state_id() == target_state:
		return SUCCESS
	
	return FAILURE
