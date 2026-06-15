class_name WorldPerception
extends Area2D

signal update_obstacles
const MAX_LEN_OBSTACLES: int = 8
var obstacles: Array[Global.ObstacleType] = []

func _check_body(body: Node2D) -> bool:
	if body is BasePlatform:    return true
	if body is GrindableObject: return true
	if body is RampMarker:      return true
	return false


func _update_obstacles_list(new_obstacle: Node2D):
	obstacles.push_back(new_obstacle)
	if len(obstacles) > MAX_LEN_OBSTACLES:
		obstacles.pop_front()
	update_obstacles.emit()


func _remove_of_obstacles(obstacle: Node2D):
	var idx := obstacles.find(obstacle)
	if idx != -1: 
		obstacles.remove_at(idx)
		update_obstacles.emit()


func _on_body_entered(body: Node2D) -> void:
	if not _check_body(body): return
	_update_obstacles_list(body)


func _on_body_exited(body: Node2D) -> void:
	if not _check_body(body): return
	_remove_of_obstacles(body)
