class_name CharacterAnimator
extends Node

signal trick_animation_finished

var character:          BaseCharacter
var anim_player:        AnimationPlayer
var is_executing_trick: bool = false
var current_trick_anim: StringName = ""


func setup(character_ref: BaseCharacter) -> void:
	character = character_ref
	
	anim_player = character.animation_player
	anim_player.animation_finished.connect(_on_animation_finished)
	
	character.state_machine.state_changed.connect(_on_state_changed)


func play_trick(anim_path: String) -> void:
	is_executing_trick = true
	current_trick_anim = anim_path
	if current_trick_anim == "tricks/":
		push_warning("The trick ", anim_path," have no anim path.")
		return
	anim_player.play(current_trick_anim)


func _on_animation_finished(anim_name: StringName) -> void:
	if is_executing_trick and anim_name == current_trick_anim:
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
			if owner is OpponentAI: anim_player.play("human/idle_op")
			elif owner is Player:   anim_player.play("human/idle")
		Global.StateID.TRICK_FAIL:
			anim_player.play("human/trick_fail")
