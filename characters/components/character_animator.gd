class_name CharacterAnimator 
extends Node2D

const START_RACE: StringName = "parameters/conditions/start_race"
const END_RACE: StringName = "parameters/conditions/end_race"
const FINISH_ANIM: StringName = "parameters/conditions/finish_anim"
const FINISH_GRIND: StringName = "parameters/conditions/finish_grind"
const IDLE_IN: StringName = "idle"
const IDLE_OUT: StringName = "idle-out"
const MOMMENTUM: StringName = "mommentum"
const TRICK_FAIL: StringName = "trick_fail"
const PUSH: StringName = "push"
const JUMP: StringName = "jump"

@export var animation_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback

var is_in_composed_anim: bool = false
var is_grind_anim: bool = false
var current_composed_anim: StringName = ""


func _finish_param(anim: StringName) -> StringName:
	return StringName("parameters/%s/conditions/finish_anim" % anim)


func _ready() -> void:
	playback = animation_tree.get("parameters/playback")


func is_loop_animation() -> bool:
	return current_composed_anim != ""


func setup(character_ref: BaseCharacter) -> void:
	character_ref.state_machine.state_changed.connect(_on_state_changed)
	character_ref.grind_component.grind_finished.connect(_on_grind_finished)


func start_race() -> void:
	_reset_composed_state()
	play_animation(IDLE_IN)
	animation_tree.set(START_RACE, true)


func end_race() -> void:
	_reset_composed_state()
	play_animation(IDLE_OUT)
	animation_tree.set(END_RACE, true)


## Normal execute animations (idle, jump, push, trick_fail)
func play_animation(anim_path: StringName) -> void:
	print("[ANIM REQUEST] ", anim_path)
	print("[ANIM CURRENT] ", playback.get_current_node())
	_reset_composed_state()
	playback.travel(anim_path)


## Trick execute
func play_trick(anim_path: StringName, is_composed: bool) -> void:
	print("[TRICK REQUEST] ", anim_path)
	print("[TRICK CURRENT] ", playback.get_current_node())
	_reset_composed_state()
	
	if is_composed:
		is_in_composed_anim = true
		current_composed_anim = anim_path
		animation_tree.set(_finish_param(anim_path), false)
		animation_tree.set(FINISH_ANIM, false)
	
	playback.start(anim_path)


func finish_composed_anim(anim_type: StringName = FINISH_ANIM) -> void:
	if not is_in_composed_anim: return
	is_in_composed_anim = false
	animation_tree.set(_finish_param(current_composed_anim), true)
	animation_tree.set(anim_type, true)


func _reset_composed_state() -> void:
	if current_composed_anim != "":
		animation_tree.set(_finish_param(current_composed_anim), false)
	
	is_in_composed_anim = false
	current_composed_anim = ""
	animation_tree.set(FINISH_ANIM, false)


func _on_grind_finished(
	reason: Global.ReasonToExitGrind,
	_data: Dictionary
) -> void:
	animation_tree.set(FINISH_GRIND, false)
	if reason == Global.ReasonToExitGrind.JUMPED:
		_force_animation(JUMP)
	elif reason == Global.ReasonToExitGrind.END_OF_RAIL:
		_force_animation(TRICK_FAIL)


func _force_animation(anim_path: StringName) -> void:
	_reset_composed_state()
	playback.start(anim_path)


func _on_state_changed(_old_state: int, new_state: int) -> void:
	match new_state:
		Global.StateID.TRICK_FAIL:
			play_animation(TRICK_FAIL)
		
		Global.StateID.ON_FLOOR:
			if is_in_composed_anim:
				finish_composed_anim()
				return
			
			play_animation(MOMMENTUM)
