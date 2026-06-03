class_name BaseState 
extends RefCounted

@warning_ignore("unused_signal")
signal transition_requested(next_state_id: Global.StateID, payload: Variant)

var character:  BaseCharacter  = null
var controller: BaseController = null
var state_id:   Global.StateID = Global.StateID.NONE

@warning_ignore("unused_parameter")
@warning_ignore("shadowed_variable")
func enter(p_character: BaseCharacter, payload = null) -> void: 
	character  = p_character
	controller = character.controller
func exit()                                          -> void: pass
func update(_delta: float)                           -> void: pass
