class_name CharacterAnimator 
extends Node2D

const FINISH_ANIM: StringName = "parameters/conditions/finish_anim"
const MOMMENTUM: StringName = "mommetum"
const TRICK_FAIL: StringName = "trick_fail"
const PUSH: StringName = "push"
const JUMP: StringName = "jump"

@export var animation_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback

var is_in_composed_anim: bool = false
var current_composed_anim: StringName = ""

func _ready() -> void:
	playback = animation_tree.get("parameters/playback")


func setup(character_ref) -> void:
	character_ref.state_machine.state_changed.connect(_on_state_changed)
	character_ref.grind_component.grind_finished.connect(_on_grind_finished)


## Normal execute animations (idle, jump, push, trick_fail)
func play_animation(anim_path: StringName) -> void:
	print("anim: ", anim_path)
	_reset_composed_state()
	playback.travel(anim_path)


## Trick execute
func play_trick(anim_path: StringName, is_composed: bool) -> void:
	print("trick: ", anim_path)
	if is_composed:
		is_in_composed_anim = true
		current_composed_anim = anim_path
		
		animation_tree.set(FINISH_ANIM, false)
	else:
		_reset_composed_state()
	
	playback.travel(anim_path)


func finish_composed_anim() -> void:
	if is_in_composed_anim:
		animation_tree.set("parameters/conditions/finish_anim", true)
		is_in_composed_anim = false


func _reset_composed_state() -> void:
	is_in_composed_anim = false
	current_composed_anim = ""
	animation_tree.set("parameters/conditions/finish_anim", false)


func _on_grind_finished(
	reason: Global.ReasonToExitGrind,
	_data: Dictionary
) -> void:
	if reason == Global.ReasonToExitGrind.JUMPED:
		play_animation(JUMP)
	elif reason == Global.ReasonToExitGrind.END_OF_RAIL:
		play_animation(TRICK_FAIL)


func _on_state_changed(_old_state: int, new_state: int) -> void:
	match new_state:
		Global.StateID.TRICK_FAIL:
			play_animation(TRICK_FAIL)
		
		Global.StateID.ON_FLOOR:
			finish_composed_anim()
			play_animation(MOMMENTUM)
