extends Node2D

@onready var rm: TutorialManager = $"../RaceManager"
var cone_group: Array[Node2D]


func _ready() -> void:
	rm.tutorial_restart.connect(_restart)
	for i in get_children():
		cone_group.append(i)


func _restart() -> void:
	for i in cone_group:
		i.restart()
