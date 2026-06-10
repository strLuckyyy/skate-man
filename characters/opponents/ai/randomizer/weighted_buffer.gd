class_name WeightedBuffer
extends RefCounted

# Ex: [80.0, 70.0, 60.0, 45.0, 35.0, 20.0, 10.0, 0.0]
# Ex: [60.0, 25.0, 0.0]
var penalty_weights: Array[float]

var _buffer:   Array = []
var _max_size: int


func _init(max_size: int, weights: Array[float]) -> void:
	_max_size       = max_size
	penalty_weights = weights.duplicate()


func push(value) -> void:
	_buffer.push_back(value)
	if _buffer.size() > _max_size:
		_buffer.pop_front()


# Retorna um item de `pool` usando penalidade de repetição.
# Itens que aparecem no buffer recebem chance reduzida baseada
func pick_weighted(pool: Array) -> Variant:
	if pool.is_empty():
		return null
	
	var weights: Array[float] = []
	var w:       float
	var idx:     int
	
	for item in pool:
		w   = 100.0
		idx = _buffer.find(item)
		
		if idx >= 0 and idx < penalty_weights.size():
			w = 100.0 - penalty_weights[idx]
		weights.append(w)
	
	return _roll(pool, weights)


func _roll(pool: Array, weights: Array[float]) -> Variant:
	var total := 0.0
	for w in weights:
		total += w
	
	if total <= 0.0:
		# Todos têm peso 0 — fallback uniforme
		return pool[randi() % pool.size()]
	
	var roll := randf() * total
	var acc  := 0.0
	for i in pool.size():
		acc += weights[i]
		if roll <= acc:
			return pool[i]
	
	return pool[-1]
