class_name StateManager
extends Node2D

@warning_ignore("unused_signal")
signal state_changed(old_state: Global.StateID, new_state: Global.StateID)


func get_current_state_id() -> Global.StateID: return Global.StateID.NONE
