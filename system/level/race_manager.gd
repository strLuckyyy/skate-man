# RaceManager.gd
class_name RaceManager
extends Node2D

enum RaceState { INIT, RACING, FINISHED }

signal race_finished(position: int)

@export var spawner: Spawner

var state: RaceState = RaceState.INIT
var finished_racers: Array = []

func is_racing() -> bool: return state == RaceState.RACING


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is BaseCharacter: return
	var b = body as BaseCharacter
	
	if b in finished_racers: return
	
	finished_racers.append(b)
	b.end_race()
	
	if body is Player:
		var pos = finished_racers.find(b) + 1
		race_finished.emit(pos)
