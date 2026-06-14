class_name AIPerceptionRadar
extends Area2D

## "Radar" de percepção do oponente IA — um Area2D fixo na frente do
## personagem que mantém, de forma persistente, listas de GrindableObjects
## e RampMarkers atualmente dentro do seu alcance.
##
## Diferente de um RayCast/ShapeCast (query pontual), esta Area2D já mantém
## o estado via body_entered/body_exited/area_entered/area_exited — então
## play_utility_action apenas LÊ o resultado já calculado, sem custo extra
## de query a cada tick.
##
## SETUP NO EDITOR (manual):
##   - Adicione este nó como filho do personagem oponente (ex: dentro de
##     base_ai.tscn / ai_john.tscn), com um CollisionShape2D filho definindo
##     a forma/alcance do radar (ex: um círculo ou retângulo na frente do
##     personagem, na direção em que ele costuma se mover).
##   - collision_mask deve incluir os layers de GrindableObject (Layer 3 =
##     "grindable") e o layer usado pelos RampMarkers que você criar no nível.
##   - GrindableObject é um Node2D (não PhysicsBody/Area2D) — a detecção real
##     acontece via a GrindArea (Area2D filha de cada GrindableObject, Layer 3).
##     Por isso este radar detecta via area_entered/area_exited (GrindArea é
##     Area2D) e resolve o GrindableObject ancestral, igual a GrindArea._get_grindable().
##   - RampMarker também é Area2D — detectado da mesma forma, sem resolução
##     de ancestral (RampMarker é o próprio nó relevante).
##
## Se o seu setup de colisão fizer GrindableObject ser detectado via
## get_overlapping_bodies() em vez de áreas, ajuste _on_area_entered /
## _on_area_exited para a variante de body — a interface pública
## (get_nearest_rail_distance/get_nearest_ramp_distance) não muda.

var _rails_in_range: Array[GrindableObject] = []
var _ramps_in_range: Array[RampMarker]      = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area is RampMarker:
		var ramp := area as RampMarker
		if not _ramps_in_range.has(ramp):
			_ramps_in_range.append(ramp)
		return

	var rail := _resolve_grindable(area)
	if rail != null and not _rails_in_range.has(rail):
		_rails_in_range.append(rail)


func _on_area_exited(area: Area2D) -> void:
	if area is RampMarker:
		_ramps_in_range.erase(area as RampMarker)
		return

	var rail := _resolve_grindable(area)
	if rail != null:
		_rails_in_range.erase(rail)


## GrindableObject não é a própria Area2D detectada — quem entra em overlap
## é a GrindArea (filha do GrindableObject). Resolve o ancestral, igual a
## GrindArea._get_grindable().
func _resolve_grindable(area: Area2D) -> GrindableObject:
	var p: Node = area.get_parent()
	while p != null:
		if p is GrindableObject:
			return p as GrindableObject
		p = p.get_parent()
	return null


## Distância (em pixels) até o GrindableObject mais próximo dentro do alcance.
## Retorna INF se nenhum estiver no alcance.
func get_nearest_rail_distance() -> float:
	if _rails_in_range.is_empty():
		return INF

	var nearest: float = INF
	var origin: Vector2 = global_position

	for rail in _rails_in_range:
		if not is_instance_valid(rail):
			continue
		var dist: float = origin.distance_to(rail.get_global_start_position())
		nearest = minf(nearest, dist)

	return nearest


## Distância (em pixels) até o RampMarker mais próximo dentro do alcance.
## Retorna INF se nenhum estiver no alcance.
func get_nearest_ramp_distance() -> float:
	if _ramps_in_range.is_empty():
		return INF

	var nearest: float = INF
	var origin: Vector2 = global_position

	for ramp in _ramps_in_range:
		if not is_instance_valid(ramp):
			continue
		var dist: float = origin.distance_to(ramp.global_position)
		nearest = minf(nearest, dist)

	return nearest


## True se há pelo menos um GrindableObject no alcance.
func has_rail_ahead() -> bool:
	return not _rails_in_range.is_empty()


## True se há pelo menos um RampMarker no alcance.
func has_ramp_ahead() -> bool:
	return not _ramps_in_range.is_empty()


## Limpa referências inválidas (objetos destruídos) das listas internas.
## Chame periodicamente se objetos do nível puderem ser deletados em runtime
## sem disparar area_exited (ex: free() direto).
func prune_invalid() -> void:
	_rails_in_range = _rails_in_range.filter(func(r): return is_instance_valid(r))
	_ramps_in_range = _ramps_in_range.filter(func(r): return is_instance_valid(r))
