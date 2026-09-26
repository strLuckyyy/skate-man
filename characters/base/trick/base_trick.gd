class_name BaseTrick
extends Node2D

@export var trick_data: TrickData

var anim_name:   StringName
var cd_timer:    Timer
var anim_sprite: CharacterAnimator


var _state_available: Array[Global.StateID]
	get:
		return _state_available.duplicate(true)


var is_grind_trick: bool:
	get:
		return trick_data != null and trick_data.is_grind_trick


func setup(_animated_sprite: CharacterAnimator) -> void:
	self.anim_sprite = _animated_sprite


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


func can_execute(_context: TrickContext) -> bool:
	if trick_data == null:        return false
	if cd_timer   == null:        return false
	if not cd_timer.is_stopped(): return false
	
	var state_id    := _context.get_state_id()
	var state_match := state_id in _state_available
	var input_match := match_input(_context.get_input_buffer())
	
	if not (state_match and input_match):
		return false
	
	if not _context.get_grind_opportunity():
		return false
	
	return true


func execute(_context: TrickContext) -> void:
	if cd_timer.is_stopped(): cd_timer.start()


##Checks if the current input buffer matches the trick's required input sequence.
func match_input(_buffer: Array[Global.Direction]) -> bool:
	var sequence = trick_data.sequence
	if _buffer.size() < sequence.size():
		return false
	
	var offset = _buffer.size() - sequence.size()
	for i in sequence.size():
		if _buffer[offset + i] != sequence[i]:
			return false
	return true


func _on_cd_timer_timeout() -> void:
	print("can execute ",  trick_data.trick_name, " again.")
