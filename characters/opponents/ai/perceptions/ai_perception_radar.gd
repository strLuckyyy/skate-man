class_name AIPerceptionRadar
extends Area2D

# Dicionário indexado pelo Enum para rastrear objetos em alcance
var _targets_in_range: Dictionary = {
	Global.TargetType.RAIL: [],
	Global.TargetType.RAMP: [],
	Global.TargetType.PLATAFORM: []
}

# Cache do alvo mais próximo atual para evitar buscas redundantes por frame
var nearest_target: Node2D = null
var nearest_distance: float = INF
var nearest_type: Global.TargetType = Global.TargetType.NONE

func _ready() -> void:
	# Garante que os sinais estão conectados corretamente
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if "target_type" in area:
		var type: Global.TargetType = area.target_type
		if _targets_in_range.has(type) and not _targets_in_range[type].has(area):
			_targets_in_range[type].append(area)
			_update_nearest_target()

func _on_area_exited(area: Area2D) -> void:
	if "target_type" in area:
		var type: Global.TargetType = area.target_type
		if _targets_in_range.has(type):
			_targets_in_range[type].erase(area)
			_update_nearest_target()

# Recalcula o objeto mais próximo de todas as listas ativas
func _update_nearest_target() -> void:
	var closest_node: Node2D = null
	var closest_dist: float = INF
	var closest_type: Global.TargetType = Global.TargetType.NONE
	
	var global_pos = global_position

	for type in _targets_in_range.keys():
		var list = _targets_in_range[type]
		# Limpa instâncias que possam ter sido deletadas do cenário no meio da corrida
		var i = list.size() - 1
		while i >= 0:
			if not is_instance_valid(list[i]):
				list.remove_at(i)
			else:
				var dist = global_pos.distance_to(list[i].global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest_node = list[i]
					closest_type = type
			i -= 1

	nearest_target = closest_node
	nearest_distance = closest_dist
	nearest_type = closest_type

# --- APIs Públicas para serem consumidas pela Inteligência Artificial ---

## Retorna a distância exata até o objeto mais próximo de um tipo específico
func get_distance_to_nearest_type(type: Global.TargetType) -> float:
	var list = _targets_in_range.get(type, [])
	if list.is_empty():
		return INF
		
	var closest_dist: float = INF
	var global_pos = global_position
	
	for node in list:
		if is_instance_valid(node):
			var dist = global_pos.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				
	return closest_dist

## Retorna se existe algum objeto daquele tipo específico no radar
func has_target_type_in_range(type: Global.TargetType) -> bool:
	return not _targets_in_range.get(type, []).is_empty()

## Retorna o nó físico do tipo específico mais próximo (útil para mirar o pulo ou encaixar no Path2D)
func get_nearest_node_of_type(type: Global.TargetType) -> Node2D:
	var list = _targets_in_range.get(type, [])
	if list.is_empty():
		return null
		
	var closest_node: Node2D = null
	var closest_dist: float = INF
	var global_pos = global_position
	
	for node in list:
		if is_instance_valid(node):
			var dist = global_pos.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_node = node
				
	return closest_node
