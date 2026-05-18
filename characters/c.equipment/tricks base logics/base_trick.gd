class_name BaseTrick
extends Node2D

#may be changed to a more specific node type later on

@export var trick_data: TrickData


func can_execute(context: TrickContext) -> bool:
	var state_available := trick_data.state_available.duplicate()
	if context.get_grind_opportunity():
		state_available.append_array(trick_data.conditional_state_available.duplicate())

	var state_match = context.get_state_id() in state_available
	var input_match = match_input(context.get_input_buffer())

	return state_match && input_match


func execute(_context: TrickContext) -> void:
	print("executing ", self.name, " logic.")
	pass


##Checks if the current input buffer matches the trick's required input sequence.
func match_input(buffer: Array[Global.Direction]) -> bool:
	var sequence = trick_data.sequence
	var continue_count: int = 0

	if buffer.size() < sequence.size():
		return false
	
	for i in range(sequence.size()):
		var buf_val = buffer[buffer.size() - sequence.size() + i]
		if int(buf_val) != int(sequence[i]):
			if continue_count == 1:
				continue_count += 1
				continue
			return false
	return true
