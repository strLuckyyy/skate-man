class_name TrickAnimator
extends Node

signal trick_animation_finished

@export var anim_tree:  AnimationTree
var is_animating_trick: bool = false

const TRICK_NODE_ANIM   = "parameters/TrickAnimation/animation"
const TRICK_ONESHOT_REQ = "parameters/TrickOneShot/request"


func setup(tree: AnimationTree) -> void:
	anim_tree = tree


func play_trick(anim_name: String) -> void:
	if is_animating_trick:
		anim_tree.set(TRICK_ONESHOT_REQ, AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	
	is_animating_trick = true
	
	anim_tree.set(TRICK_NODE_ANIM, anim_name)	
	anim_tree.set(TRICK_ONESHOT_REQ, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _process(_delta: float) -> void:
	if not is_animating_trick: return
	
	var is_active = anim_tree.get("parameters/TrickOneShot/active")
	
	if not is_active:
		is_animating_trick = false
		trick_animation_finished.emit()
