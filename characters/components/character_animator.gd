
class_name CharacterAnimator
extends AnimatedSprite2D

signal trick_animation_finished

var character:          BaseCharacter
var is_executing_trick: bool = false
var current_trick_anim: StringName = ""


func setup(character_ref: BaseCharacter) -> void:
	character   = character_ref
	
	animation_finished.connect(_on_animation_finished)
	character.state_machine.state_changed.connect(_on_state_changed)


func is_loop_animation(anim_name: StringName = "") -> bool:
	if anim_name == "": anim_name = current_trick_anim
	if sprite_frames == null:
		return false
	
	if sprite_frames.has_animation(anim_name):
		return sprite_frames.get_animation_loop(anim_name)
	
	return false


## Method to call a trick animation. If you need to call a normal animation, call play_animation() instead.
func play_trick(anim_path: StringName) -> void:
	if anim_path.is_empty():
		push_warning("A manobra '", anim_path, "' não tem nome de animação válido.")
		is_executing_trick = false
		return
	
	if character.state_machine.get_current_state_id() == Global.StateID.TRICK_FAIL:
		return

	is_executing_trick = true
	current_trick_anim = anim_path
	print("Playing trick animation: ", anim_path)
	play(anim_path)


## Method to call a normal animation. If you need to call a trick animation, call play_trick() instead.
func play_animation(anim_path: StringName, forced: bool = false) -> void:
	if character.state_machine.get_current_state_id() == Global.StateID.TRICK_FAIL:
		if anim_path != "trick_fail":
			return
	
	if is_executing_trick and not forced: return
	if forced and not is_loop_animation(current_trick_anim): return

	current_trick_anim = anim_path
	play(anim_path)


func _on_animation_finished() -> void:
	if is_executing_trick and animation == current_trick_anim:
		is_executing_trick = false
		trick_animation_finished.emit()
		_update_base_animation(character.state_machine.get_current_state_id())


func _on_state_changed(_old_state: Global.StateID, new_state: Global.StateID) -> void:
	if new_state == Global.StateID.TRICK_FAIL: 
		is_executing_trick = false
	
	if is_executing_trick:
		return
	
	_update_base_animation(new_state)


func _update_base_animation(state_id: Global.StateID) -> void:
	match state_id:
		Global.StateID.ON_FLOOR:
			play_animation("mommentum")
		Global.StateID.TRICK_FAIL:
			play_animation("trick_fail")
