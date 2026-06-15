@tool
class_name BTActionJump
extends BTAction

func _tick(_delta: float) -> int:
	var agent_char := agent as BaseCharacter
	if not agent_char: return FAILURE
	
	if agent_char.is_on_floor():
		agent_char.apply_jump()
		return SUCCESS
		
	return RUNNING
