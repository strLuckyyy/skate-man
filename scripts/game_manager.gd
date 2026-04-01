extends Node

var player_ref: Player

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
