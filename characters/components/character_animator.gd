
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


## Method to call a trick animation. If you need to call a normal animation, call play_animation() instead.
func play_trick(anim_path: StringName) -> void:
	is_executing_trick = true
	if anim_path.is_empty() or anim_path == "tricks/":
		push_warning("A manobra '", anim_path, "' não tem nome de animação válido.")
		is_executing_trick = false
		return
	play_animation(anim_path)


## Method to call a normal animation. If you need to call a trick animation, call play_trick() instead.
func play_animation(anim_path: StringName) -> void:
	if is_executing_trick: return
	current_trick_anim = anim_path
	print("Playing animation: ", anim_path)
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
			play("mommentum")
		Global.StateID.TRICK_FAIL:
			play("trick_fail")
