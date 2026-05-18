class_name BaseState 
extends RefCounted

@warning_ignore("unused_signal")
signal transition_requested(next_state_name: BaseState)

var character: CharacterBody2D = null
var state_id: Global.StateID = Global.StateID.NONE

@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable")
func enter(character: CharacterBody2D, payload = null) -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass
