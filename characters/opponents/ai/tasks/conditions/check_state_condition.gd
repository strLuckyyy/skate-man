@tool
extends BTCondition

@export var target_state: Global.StateID
@export var secound_target_state: Global.StateID = Global.StateID.NONE

func _tick(_delta: float) -> Status:
	var character: BaseCharacter = agent as BaseCharacter
	if character == null or character.state_machine == null:
		return FAILURE
	
	var target = [target_state]
	if secound_target_state != Global.StateID.NONE:
		target.append(secound_target_state)
	
	if character.state_machine.get_current_state_id() in target:
		return SUCCESS
	
	return FAILURE
