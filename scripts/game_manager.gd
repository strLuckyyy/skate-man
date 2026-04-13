extends Node

var player_ref: Player
var opponent_ref: BaseCharacter

func _ready() -> void:
	get_player()
	get_opponent()


func get_opponent():
	opponent_ref = get_tree().get_first_node_in_group("opponent")


func get_player():
	player_ref = get_tree().get_first_node_in_group("player")
