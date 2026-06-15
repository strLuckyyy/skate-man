class_name BaseTrick
extends Node2D

@export var trick_data: TrickData
var anim_name:         StringName
var _state_available:   Array[Global.StateID]
var is_grind_trick:     bool = false
var cd_timer:           Timer
var anim_player:        AnimationPlayer


func get_state_available() -> Array[Global.StateID]: 
	return _state_available.duplicate(true)


func _ready() -> void:
	_state_available = trick_data.state_available.duplicate()
	if trick_data.conditional_state_available.size() > 0:
		_state_available.append_array(
			trick_data.conditional_state_available.duplicate())
	
	anim_name          = trick_data.animation_name
	cd_timer           = Timer.new()
	cd_timer.wait_time = trick_data.cd
	cd_timer.one_shot  = true
	
	add_child(cd_timer)
	cd_timer.timeout.connect(_on_cd_timer_timeout)


func set_anim_player(animation_player: AnimationPlayer) -> void:
	anim_player = animation_player


func can_execute(context: TrickContext) -> bool:
	var state_id    := context.get_state_id()
	var state_match := state_id in _state_available
	var input_match := match_input(context.get_input_buffer())
	
	if not cd_timer.is_stopped():
		return false
	
	if not (state_match and input_match):
		return false
	
	if is_grind_trick and Global.StateID.ON_GRIDING in _state_available:
		if not context.get_grind_opportunity():
			return false
	
	return true


func execute(_context: TrickContext) -> void:
	if cd_timer.is_stopped(): cd_timer.start()
	print("executing ", self.name, " logic.")
	pass


##Checks if the current input buffer matches the trick's required input sequence.
func match_input(buffer: Array[Global.Direction]) -> bool:
	var sequence = trick_data.sequence
	if buffer.size() < sequence.size():
		return false
	
	var offset = buffer.size() - sequence.size()
	for i in sequence.size():
		if buffer[offset + i] != sequence[i]:
			return false
	return true


func _on_cd_timer_timeout() -> void:
	print("can execute ",  trick_data.trick_name, " again.")
